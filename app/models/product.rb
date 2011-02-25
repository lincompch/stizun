class Product < ActiveRecord::Base
  
  validates_uniqueness_of :manufacturer_product_code
  validates_presence_of :name, :description, :weight, :tax_class_id, :supplier_id
  validates_numericality_of :purchase_price, :weight
  
  # Something's not right here when creating independent products
  #validates_uniqueness_of :supply_item_id
  
  
  # Self-referential association to build products out of
  # other products (e.g. a PC out of components)
  #
  # Calculate prices inside e.g.
  # product.product_sets.first.price.rounded
  has_many :components, :through => :product_sets
  has_many :product_sets, :foreign_key => 'product_id', :class_name => 'ProductSet'
  
  has_many :product_pictures
  has_many :attachments
  
  belongs_to :tax_class
  belongs_to :supply_item
  has_many :document_lines
  has_and_belongs_to_many :categories
  
  belongs_to :supplier
  
  scope :available, :conditions => { :is_available => true }
  scope :supplied, :conditions => "supply_item_id IS NOT NULL"
  scope :loss_leaders, :conditions => { :is_loss_leader => true }
  scope :on_sale, :conditions => { :sale_state => true }

  before_save :set_explicit_sale_state
  after_create :try_to_get_product_files
  
  
  # Thinking Sphinx configuration
  # Must come AFTER associations
  define_index do
    # fields
    indexes name, :sortable => true
    indexes purchase_price, :sortable => true
    indexes manufacturer, short_description, description, supplier_product_code, manufacturer_product_code
    
    # attributes
    has id, created_at, updated_at, is_available
    
    set_property :delta => true
  end

  sphinx_scope(:sphinx_available) {
    {
    :conditions => { :is_available => 1}
    }
  }
  
  
  # Pagination with will_paginate
  def self.per_page
    return 50
  end
  
  def price
    gross_price - calculate_rebate(gross_price)
  end
  
  def taxed_price
    price + taxes
  end
  
  # The gross price is the price + margin (or sales price, in case of absolutely
  # priced goods). Taxes and rebate are not yet processed here.
  def gross_price
    if componentized?
      gross_price = component_gross_price
    else
      absolutely_priced? ? gross_price = sales_price : gross_price = calculated_gross_price
    end
     
    return gross_price
  end
  
  def calculate_rebate(full_price)
    rebate = BigDecimal.new("0")
    end_date = rebate_until || DateTime.new(1940,01,01) 
    
    if DateTime.now < end_date
      if absolute_rebate?
        rebate = absolute_rebate
      elsif percentage_rebate?
        rebate = (full_price / BigDecimal.new("100.0")) * percentage_rebate
        rebate = rebate.rounded
      end
    end
    # This check makes sure only loss-leader products can go below their purchase
    # price through a rebate.
    if (full_price - rebate) < purchase_price
      unless is_loss_leader?
        rebate = 0
      end
    end 
    return rebate
  end
  
  def rebate
    calculate_rebate(gross_price)
  end
  
  def absolute_rebate?
    !absolute_rebate.blank? and absolute_rebate > 0
  end
  
  def percentage_rebate?
    !percentage_rebate.blank? and percentage_rebate > 0
  end
  
  
  # Returns the taxes owed on the sales price of a product. 
  def taxes
    calculation = BigDecimal.new("0")
    absolutely_priced? ? base_price = sales_price : base_price = gross_price
    calculation = ( (base_price - rebate) / BigDecimal.new("100.0")) * tax_class.percentage
    calculation
  end
  
  def margin
    if componentized?
      component_margin
    else
      if absolutely_priced?
        sales_price - purchase_price
      else
        calculated_margin
      end
    end
  end
  
  # Calculates all three pricing items (gross price, margin and compound purchase price) for products
  # that consist of multiple products. This assigns all three results in one go so that
  # a lot less calculation is necessary.
  def calculate_component_pricing
    purchase_price = BigDecimal.new("0")
    price = BigDecimal.new("0")
    margin = BigDecimal.new("0")
    # Safeguard to prevent calculation on straightforward simple products
    if componentized?  
      self.product_sets.each do |ps|
        # Components can disappear if their supply items disappear.
        # This is handled more elegantly by disabling these components from outside
        # when this occurs, but let's check for this here just to be safe.
        unless ps.component.nil?
          purchase_price += ps.quantity * ps.component.purchase_price
        end
      end
      # We must use the compound product's tax class for legal reasons, no matter what
      # tax class the constituent components may have.
            
      margin = (purchase_price / BigDecimal.new("100.0")) * self.margin_percentage
      gross_price = purchase_price + margin
    end
    @component_pricing ||= [gross_price, margin, purchase_price]
    return @component_pricing
  end
  
  def component_gross_price
    calculate_component_pricing
    return @component_pricing[0]
  end
  
  def component_margin    
    calculate_component_pricing
    return @component_pricing[1]
  end
  
  def component_purchase_price
    calculate_component_pricing
    return @component_pricing[2]
  end
  

  
  def add_component(product, quantity = 1)
    unless product.class.name == "SupplyItem"
      raise ArgumentError, "Only supply items can be added as components to other products."
    end

    incremented = false
    saved = false
    
    self.product_sets.each do |ps|
      # Found an existing product set with the same component/product
      # pair, thus we just augment
      if ps.component == product
        ps.quantity += quantity
        if ps.save
          incremented = true
          saved = true
        end
      end
    end
    
    # No existing pair was found, we need to create a new one
    if incremented == false
      ps = ProductSet.new
      ps.quantity = quantity
      ps.component = product
      ps.product = self
      if ps.save
        saved = true
        self.reload
      end
    end
    return saved
  end
  
  
  def remove_component(component, quantity)
    result = false
    quantity = quantity.to_i
    
    self.product_sets.each do |ps|
      if ps.component == component
        if (ps.quantity - quantity) <= 0
          result = true if ps.destroy
        else
          ps.quantity = ps.quantity - quantity
          result = true if ps.save
        end
        self.reload
      end
    end
    return result
  end
  
  # Returns how many of these products we could build based on the stock levels of
  # its components at our suppliers.  
  def component_stock
    stock_levels = []
    product_sets.each do |ps|
      # If any component's stock is below the required quantity, we can impossibly
      # put together this product, so stock becomes immediately 0 as soon as we
      # hit one of these combinations.
      if ps.quantity > ps.component.stock
        stock_levels = [0]
        break        
      else
        # Since we are computing stock from integers, we will always receive the maximum
        # number of constructable products per component from the division.
        # Just as if we had used this more explicit calcluation:
        # (ps.component.stock.to_f / ps.quantity.to_f).floor
        stock_levels << (ps.component.stock.to_i / ps.quantity.to_i)
      end
    end
    return stock_levels.min
  end
  
  
  def self.new_from_supply_item(si)
    p = self.new
    p.name = si.name
    p.manufacturer = si.manufacturer
    p.product_link = si.product_link
    p.description = si.description
    p.purchase_price = si.purchase_price
    # Can be improved by flexibly reading the tax percentage from the CSV file in a first
    # step and then assigning it to a supply item, and THEN reading a proper TaxClass object from there
    p.tax_class = TaxClass.find_by_percentage("8.0")
    p.margin_percentage = 5.0
    p.supplier_id = si.supplier_id
    p.supply_item_id = si.id
    p.weight = si.weight
    p.supplier_product_code = si.supplier_product_code
    p.manufacturer_product_code = si.manufacturer_product_code
    p.stock = si.stock
    return p
  end

  def to_s
    return "#{id} #{name}"
  end  
  
  # CSV export functions.
  
  # Generate a header matching the kind of columns that are actually available for
  # our Product objects.
  def self.csv_header
    ["id","manufacturer_product_code","name","description", "price_excluding_vat", "price_including_vat", "price_including_shipping", "vat", "shipping_cost", "stock", "availability", "weight_in_kg", "link"]
  end
  
  # Convert this particular product instance into a CSV-compatible representation
  # that matches the header columns as given by Product.csv_header
  def to_csv_array
    c = Cart.new
    c.add_product(self)
    shipped_price = (taxed_price.rounded + c.shipping_cost.rounded)
    availability = "48h"
    if stock < 1
      availability = "ask"
    end
    # We use string interpolation notation (#{foo}) so that nil errors are already
    # handled gracefully without any extra work.
    ["#{id}", "#{manufacturer_product_code}", "#{name}", "#{description}", "#{price.rounded}", "#{taxed_price.rounded}", "#{shipped_price}", "#{taxes}", "#{c.shipping_cost.rounded}", "#{stock}", "#{availability}", "#{weight}", "http://www.lincomp.ch/products/#{self.id}"]
  end
  
  def calculated_margin_percentage
    percentage = (BigDecimal.new("100.0") / gross_price) * margin
    BigDecimal.new(percentage.to_s)
  end
  
  
  # Boolean statuses that need processing (non-trivial booleans that can't be handled by ActiveRecord itself)
  
  def in_a_document?
    state = false
    state = true if document_lines.count > 0
    return state
  end
  
  def componentized?    
    !self.components.empty?
  end
  
  def on_sale?
    rebate > 0
  end

  
    # Is this product priced via an absolutely defined sales price?
  def absolutely_priced?
    if sales_price.nil? or sales_price.blank? or sales_price == BigDecimal.new("0.0")
      return false
    else
      return true
    end
  end
  
  def profitable?
    price > purchase_price
  end
 
 
  def available?
    is_available == true
  end
  
  def thumbnail_picture
    pic = product_pictures.main.first
    if pic.nil?
      pic = product_pictures.first
    end
    return pic
  end
  
  def set_explicit_sale_state
    self.sale_state = false
    self.sale_state = true if on_sale?
  end
  
  # Attribute overrides
  
  def weight
    weight = 0
    if self.componentized?
      self.product_sets.each do |ps|
        weight += ps.weight
      end
    else
      weight = read_attribute :weight
    end
    
    return weight
  end
  
  def purchase_price
    if self.componentized?
      return self.component_purchase_price
    else
      return read_attribute :purchase_price
    end
  end
  
  def stock
    if self.componentized?
      return self.component_stock
    else
      return read_attribute :stock
    end    
  end
  
  
  def disable_product
    self.is_available = false
    if self.save
      History.add("Disabled product #{self.to_s}.", History::PRODUCT_CHANGE, self)
    else
      History.add("Could not disable product #{self.to_s}.", History::PRODUCT_CHANGE, self)
    end
  end

  def has_unavailable_supply_item?
    unless self.supply_item.blank?
      self.supply_item.status_constant != SupplyItem::AVAILABLE
    end
  end
  
  def has_unavailable_components?
      self.components.unavailable.count > 0
  end
  
  def unavailable_components
    if self.componentized?
      self.components.unavailable
    end
  end

  # Returns a URL pointing to that particular product on the supplier's web page
  def supplier_detail_link
    if supplier.product_base_url.blank? or self.supplier_product_code.blank?
      return nil
    else
      return "#{supplier.product_base_url}#{self.supplier_product_code}"
    end
  end

  
  # Compare all products that are related to a supply item with
  # the supply item's current stock level and price. Make adjustments
  # as necessary.
  def self.update_price_and_stock
    Product.suspended_delta do
      Product.supplied.each do |p|
        # The supply item is no longer available, thus we need to
        # make our own copy of it unavailable as well

        # The product has a supplier, but its supply item is gone
        if p.supply_item.nil? and !p.supplier_id.blank?
          self.disable_product(p)
          History.add("Disabled product #{p.to_s} because its supply item is gone.", History::PRODUCT_CHANGE,  p)
        else
          # Disabling product because we would be incurring a loss otherwise
          if (p.absolutely_priced? and p.supply_item.purchase_price > p.sales_price)
            p.is_available = false
            p.save
            History.add("Disabled product #{p.to_s} because purchase price is higher than absolute sales price.", History::PRODUCT_CHANGE,  p)

          # Nothing special to do to this product -- just update some fields
          else
            p.sync_from_supply_item(p.supply_item)
          end
        end
      end
    end
  end
  
  def sync_from_supply_item(supply_item = self.supply_item)
    self.stock = self.supply_item.stock
    self.purchase_price = self.supply_item.purchase_price
    self.manufacturer_product_code = self.supply_item.manufacturer_product_code
    changes = self.changes
    result = self.save
    if result == true
      History.add("Product update: #{self.to_s}. Changes: #{changes.inspect}", History::PRODUCT_CHANGE, p)
    else
      History.add("Product update failed: #{self.to_s}. Changes: #{changes.inspect}. Errors: #{self.errors.full_messages}", History::PRODUCT_CHANGE, p)
    end
    return result
  end


  def try_to_get_product_files
    unless self.supply_item.nil?
      if self.supply_item.retrieve_product_picture
        if self.product_pictures.count == 1
          self.product_pictures.first.set_main_picture
        end
      end
      self.supply_item.retrieve_pdf
    end
  end
  
  def alternative_supply_items?
    alternative_supply_items.count > 0
  end
  
  def alternative_supply_items
    SupplyItem.where(:manufacturer_product_code => supply_item.manufacturer_product_code) - [supply_item]

  end

  
  private
 
  
  def calculated_rounded_gross_price
    calculated_rounded_sales_price = calculated_gross_price.round(1)
    BigDecimal.new(calculated_rounded_gross_price.to_s)
  end
  
  def calculated_gross_price
    calculated_gross_price = (purchase_price + calculated_margin)
    BigDecimal.new(calculated_gross_price.to_s)
  end
  
  def calculated_margin
    margin = (purchase_price / 100.0) * margin_percentage
    BigDecimal.new(margin.to_s)
  end

  
end

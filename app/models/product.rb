class Product < ActiveRecord::Base

  validates_uniqueness_of :name
  validates_presence_of :name, :description, :tax_class_id
  validates_numericality_of :purchase_price
  
  # Something's not right here when creating independent products
  #validates_uniqueness_of :supply_item_id
  
  
  # Self-referential association to build products out of
  # other products (e.g. a PC out of components)
  #
  # Calculate prices inside e.g.
  # product.product_sets.first.rounded_price
  has_many :components, :through => :product_sets
  has_many :product_sets, :foreign_key => 'product_id', :class_name => 'ProductSet'
  
  belongs_to :tax_class
  belongs_to :supply_item
  has_many :document_lines
  has_and_belongs_to_many :categories
  
  belongs_to :supplier
  
  named_scope :available, :conditions => { :is_available => true }
  named_scope :supplied, :conditions => "supply_item_id IS NOT NULL"
  named_scope :loss_leaders, :conditions => { :is_loss_leader => true }
  
  
  # Pagination with will_paginate
  def self.per_page
    return 50
  end
  
  def rounded_price
    # Round to the nearest 0.5 because in our currency (CHF), 0.1 and 0.2 don't exist
    rounded_price = ( price/BigDecimal("5") ).round(2) * BigDecimal("5")  
    return rounded_price
  end
  
  def price
    if absolutely_priced?
      gross_price - calculate_rebate(gross_price)
    else
      gross_price - calculate_rebate(gross_price) + taxes
    end
  end
  
  # The gross price is the price + margin (or sales price, in case of absolutely
  # priced goods). Taxes and rebate are not yet processed here.
  def gross_price
    if componentized?
      gross_price = component_gross_price
    else
      if absolutely_priced?
        gross_price = sales_price
      else
        gross_price = calculated_gross_price
      end
    end
     
    return gross_price
  end
  
  def calculate_rebate(price)
    rebate = BigDecimal.new("0")
    end_date = rebate_until || DateTime.new(1940,01,01) 
    
    if DateTime.now < end_date
      if !absolute_rebate.blank? and absolute_rebate > 0
        rebate = absolute_rebate
      elsif !percentage_rebate.blank? and percentage_rebate > 0
        rebate = (((price / 100.0) * percentage_rebate) / BigDecimal("5")).round(2) * BigDecimal("5")  
      end
    end
    
    # This check makes sure only loss-leader products can go below their purchase
    # price through a rebate.
    if (price - rebate) < purchase_price
      unless is_loss_leader?
        rebate = 0
      end
    end
    
    return rebate
  end
  
  def rebate
    calculate_rebate(price)
  end
  
  def taxes
    calculation = 0
    if absolutely_priced?
      calculation = (sales_price  / (100.0 + tax_class.percentage)) * tax_class.percentage
    else
      calculation = (gross_price / 100.0) * tax_class.percentage
    end
    BigDecimal.new(calculation.to_s)
  end
  
  def margin
    if componentized?
      component_margin
    else
      if absolutely_priced?
        sales_price - purchase_price - taxes
      else
        calculated_margin
      end
    end
  end
  
  def price_before_rebate
    return price + rebate
  end
  
  def rounded_price_before_rebate
    return rounded_price + rebate
  end
  
  
  # Calculates all three pricing items (price, taxes and margin) for products
  # that consist of multiple products. This assigns all three results in one go so that
  # a lot less calculation is necessary.
  def calculate_component_pricing
    purchase_price = BigDecimal.new("0")
    price = BigDecimal.new("0")
    margin = BigDecimal.new("0")
    # Safeguard to prevent calculation on straightforward simple products
    if componentized?  
      self.product_sets.each do |ps|
        purchase_price += ps.quantity * ps.component.purchase_price
      end
      # We must use the compound product's tax class for legal reasons, no matter what
      # tax class the constituent components may have.
            
      margin = (purchase_price / 100.0) * self.margin_percentage
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
  
  
  # More or less formatting-related methods. They are useful
  # in views. Could be refactored to views or perhaps helpers if necessary.
  def pretty_margin
    if (purchase_price > 0 and margin > 0)
      if self.componentized?
        percent_string = calculated_margin_percentage.round(3).to_s
      else
        percent_string = ((100/purchase_price) * margin).round(3).to_s
      end
      
       string = sprintf "%.2f", margin
       pretty_margin = percent_string + "% = " + string
    else
      return sprintf "%.2f", 0
    end
  end
  
  def pretty_taxes
    string = sprintf "%.2f", taxes
    tax_class.percentage.round(3).to_s + "% = " + string
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
    p.description = si.description
    p.purchase_price = si.purchase_price
    # Can be improved by flexibly reading the tax percentage from the CSV file in a first
    # step and then assigning it to a supply item, and THEN reading a proper TaxClass object from there
    p.tax_class = TaxClass.find_by_percentage("7.6")
    p.margin_percentage = 5.0
    p.supplier_id = si.supplier_id
    p.supply_item_id = si.id
    p.weight = si.weight
    p.supplier_product_code = si.supplier_product_code
    p.manufacturer_product_code = si.manufacturer_product_code
    p.stock = si.stock
    return p
  end

  # Compare all products that are related to a supply item with
  # the supply item's current stock level and price. Make adjustments
  # as necessary.
  def self.update_price_and_stock
    
    self.supplied.each do |p|
      # The supply item is no longer available, thus we need to
      # make our own copy of it unavailable as well
      
      # The product has a supplier, but its supply item is gone
      if p.supply_item.nil? and !p.supplier_id.blank?
        p.is_available = false
        p.save
        History.add("Disabled product #{p.to_s} because it is no longer available at supplier.", p)
      else
        # Disabling product because we would be incurring a loss otherwise
        if (p.absolutely_priced? and p.supply_item.purchase_price > p.sales_price)
          p.is_available = false
          p.save
          History.add("Disabled product #{p.to_s} because purchase price is higher than absolute sales price.", p)
          
        # Nothing special to do to this product -- just update price and stock
        else
          old_stock = p.stock
          old_price = p.purchase_price.to_s
          p.stock = p.supply_item.stock
          p.purchase_price = p.supply_item.purchase_price
          p.save
          History.add("Product update: #{p.to_s} price from #{old_price} to #{p.purchase_price}, stock from #{old_stock} to #{p.stock}", p)
        end
        
      end

    end
    
  end

  def to_s
    return "#{id} #{name}"
  end

  
  
  # CSV export functions.
  
  # Generate a header matching the kind of columns that are actually available for
  # our Product objects.
  def self.csv_header
    ["id","manufacturer_product_code","name","description", "price_excluding_vat", "price_including_vat", "price_including_shipping", "vat", "shipping_cost", "stock", "availability", "weight_in_kg"]
  end
  
  # Convert this particular product instance into a CSV-compatible representation
  # that matches the header columns as given by Product.csv_header
  def to_csv_array
    c = Cart.new
    c.add_product(self)
    shipped_price = (rounded_price + c.shipping_cost)
    availability = "24h"
    if stock < 1
      availability = "ask"
    end
    # We use string interpolation notation (#{foo}) so that nil errors are already
    # handled gracefully without any extra work.
    ["#{id}", "#{manufacturer_product_code}", "#{name}", "#{description}", "#{net_price}", "#{rounded_price}", "#{shipped_price}", "#{taxes}", "#{c.shipping_cost}", "#{stock}", "#{availability}", "#{weight}"]
  end
  
  def calculated_margin_percentage
    percentage = (100.0 / gross_price) * margin
    BigDecimal(percentage.to_s)
  end
  
  
  # Boolean statuses that need processing (non-trivial booleans that can't be handled by ActiveRecord itself)
  
  def in_a_document?
    state = false
    state = true if document_lines.count > 0
    return state
  end
  
  def componentized?
    self.components.count > 0
  end
  
  def on_sale?
    self.rebate > 0
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
    gross_price > purchase_price
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
    BigDecimal(margin.to_s)
  end

  
end

class ShippingRate < ActiveRecord::Base
  
  has_many :shipping_costs 
  has_many :suppliers
  belongs_to :tax_class
  
  validates_presence_of :name
  validates_presence_of :tax_class_id
  
  
  # Input: Weight in grams
  # Output: Price for delivery according to associated ShippingCosts
  def calculate_for_weight(weight)
    @total_cost = BigDecimal.new("0")
    @total_taxes = BigDecimal.new("0")
    @remaining_weight ||= weight  # shouldn't really be an instance variable, but scope seems weird below otherwise?
    
#     puts "\n\nbeginning of calculate_for_weight:"
#     puts "   shipping_rate: #{self.inspect}"
#     puts "   shipping_costs: #{shipping_costs.inspect}"
#     puts "   weight: #{weight}" unless weight.nil?
#     dbg
    
    while @remaining_weight > 0.to_f

      # The weight is too high to fit into one package, we pick this supplier's highest-weight
      # shipping rate, reduce the remaining weight and continue with the rest of the weight (this splits
      # orders into multiple packages)
      if @remaining_weight > self.maximum_weight
        @remaining_weight = (@remaining_weight - self.maximum_weight)
        matching_cost = self.shipping_costs.select{|s| s.weight_max == self.maximum_weight}.first
      else
        
        shipping_cost = self.shipping_costs.select{ |sc| @remaining_weight.between?(sc.weight_min, sc.weight_max) }
        if shipping_cost.blank?
          # No shipping cost was found that matches the weight of this order
          # so we assume the order is below the lowest weight and pick the first
          # shipping cost of this supplier
          matching_cost = self.shipping_costs.first
          @remaining_weight -= @remaining_weight
          
        else
          # A match was found, the weight is between two available shipping rates (shipping_cost.first is this rate)
          matching_cost = shipping_cost.first
          @remaining_weight -= @remaining_weight
        end
      end
      
      # Add the prices of the matching shipping cost that was found above
      @total_cost += matching_cost.taxed_price
      @total_taxes += matching_cost.taxes
      
    end
    
#     puts "end of calculate_for_weight:"
#     puts "   weight: #{weight}" unless weight.nil?
#     dbg
#     puts "\n\n"
    return BigDecimal.new(@total_cost.to_s), BigDecimal.new(@total_taxes.to_s)
  end
  
  # Input: Weight in grams
  # Output: Integer representing the number of packages necessary to ship
  #         items as heavy as the input weight.
  def package_count_for_weight(weight)
    (weight / self.maximum_weight).ceil
  end
  
  
  # Calculates incoming shipping cost for all the items in a document. Takes into account
  # whether they ship directly from manufacturer to customer or whether they have to be
  # shipped twice, once to a workshop and from there to the customer
  def calculate_incoming(document)
    @total_weight = 0
    @incoming_cost = BigDecimal.new("0")
    @incoming_taxes = BigDecimal.new("0")
    @incoming_package_count = 0
    
#     puts "\nbeginning of calculate_incoming:"
#     dbg

    # On direct shipping orders, incoming cost is always 0, we can skip expensive
    # calculations on this document.
    unless document.direct_shipping?

      # We do incoming shipping calculation on a flattened set of all products
      # necessary for this order. That includes incoming supply items _and_ complete
      # products that we order and ship directly to the customer
      supplier_ids = document.existing_incoming_supplier_ids
      supplier_ids.each do |sup_id|
        this_suppliers_weight = 0
        this_suppliers_products_and_supply_items = document.incoming_products_and_supply_items.select{ |p| p.supplier_id == sup_id }
        this_suppliers_products_and_supply_items.each do |p|
          this_things_weight = document.quantity_of(p) * p.weight
          this_suppliers_weight += this_things_weight
          @total_weight += this_things_weight
        end
        
        added_cost, added_taxes = Supplier.find(sup_id).shipping_rate.calculate_for_weight(this_suppliers_weight * 1000)
        @incoming_cost += added_cost
        @incoming_taxes += added_taxes
        @incoming_package_count += Supplier.find(sup_id).shipping_rate.package_count_for_weight(document.weight * 1000)

      end
    end
#     puts "end of calculate_incoming"
#     dbg
#     puts "\n\n"
    
  end
  
  def calculate_outgoing(document)
    @outgoing_cost = BigDecimal.new("0")
    @outgoing_taxes = BigDecimal.new("0")
    
#      puts "beginning of calculate_outgoing:"
#      puts "   document: #{document.to_s}"
#      
    if document.direct_shipping?
      # This is safe because Document#direct_shipping? checks to make sure there is only one
      # supplier. 
      sr = ShippingRate.find(document.suppliers.first.shipping_rate.id)
      direct_shipping_fee_taxes = (sr.direct_shipping_fees / BigDecimal.new("100.0")) * sr.tax_class.percentage
      # This was shipped directly, so let's add those fees
      @outgoing_taxes += direct_shipping_fee_taxes
      @outgoing_cost += sr.direct_shipping_fees + direct_shipping_fee_taxes
    else
      sr = ShippingRate.get_default
    end
    added_cost, added_taxes = sr.calculate_for_weight(document.weight * 1000)
    @outgoing_cost += added_cost
    @outgoing_taxes += added_taxes
    @outgoing_package_count = sr.package_count_for_weight(document.weight * 1000)
#     puts "at end of calculate_outgoing:"
#     dbg
#     puts "\n\n"
  end
    
  # Can calulate shipping for both orders or carts (= documents)
  def calculate_for(document)
    calculate_incoming(document)
    calculate_outgoing(document)
  end
  
  def incoming_cost
    @incoming_cost or BigDecimal.new("0.0")
  end

  def outgoing_cost
    @outgoing_cost or BigDecimal.new("0.0")
  end
  
  def incoming_package_count
    @incoming_package_count or 0
  end
  
  def outgoing_package_count
    @outgoing_package_count or 0
  end
  
  # Total cost (including VAT)
  def total_cost
    incoming_cost + outgoing_cost
  end
  
  # Total of incoming and outgoing taxes
  def total_taxes
    (@incoming_taxes + @outgoing_taxes) or BigDecimal.new("0.0")
  end
 
  
  # Maximum weight carried by this ShippingRate's ShippingCosts, in grams
  def maximum_weight
    self.shipping_costs.collect(&:weight_max).max
  end
  
  
  def self.get_default
    
    sr = ShippingRate.where(:default => true).first
    if sr.nil?
      sr = ShippingRate.new(:name => 'Auto-created default shipping rate', :default => true)  
      tc = TaxClass.find_or_create_by_percentage_and_name("8.0", "Auto-created default tax class")
      sr.tax_class = tc
      # Source: http://www.post.ch/post-startseite/post-privatkunden/post-versenden/post-pakete-inland/post-pakete-inland-preise.htm
      sr.shipping_costs << ShippingCost.create(:weight_min => 0, :weight_max => 2000, :price => 8.35, :tax_class => tc)
      sr.shipping_costs << ShippingCost.create(:weight_min => 2001, :weight_max => 5000, :price => 10.20, :tax_class => tc)
      sr.shipping_costs << ShippingCost.create(:weight_min => 5001, :weight_max => 10000, :price => 11.10, :tax_class => tc)
      sr.shipping_costs << ShippingCost.create(:weight_min => 10001, :weight_max => 20000, :price => 16.70, :tax_class => tc)
      sr.shipping_costs << ShippingCost.create(:weight_min => 20001, :weight_max => 30000, :price => 23.15, :tax_class => tc)
      
      sr.save
    end
    
    return sr
  end
  
  # debug print to analyze why two different systems, both running squeeze and
  # ruby 1.8.7, would produce completely different tax calculations
  def dbg
    puts "   @incoming_package_count: #{@incoming_package_count}" unless @incoming_package_count.nil?
    puts "   @outgoing_package_count: #{@outgoing_package_count}" unless @outgoing_package_count.nil?
    puts "   @remaining_weight: #{@remaining_weight}" unless @remaining_weight.nil?
    puts "   @incoming_cost: #{@incoming_cost}" unless @incoming_cost.nil?
    puts "   @outgoing_cost: #{@outgoing_cost}" unless @outgoing_cost.nil?
    puts "   @incoming_taxes: #{@incoming_taxes}" unless @incoming_taxes.nil?
    puts "   @outgoing_taxes : #{@outgoing_taxes}" unless @outgoing_taxes.nil?
    puts "   @total_taxes : #{@total_taxes}" unless @total_taxes.nil?
    puts "   @total_cost : #{@total_cost}" unless @total_cost.nil?

  end
  
end

class Document < ActiveRecord::Base
  self.abstract_class = true

  
  def taxed_price
    return products_taxed_price + shipping_rate.total_cost
  end
  
  def products_taxed_price
    total = BigDecimal.new("0.0")
    self.lines.each do |ol|
      total += ol.taxed_price
    end
    return total    
  end
  
  def products_price
    total = BigDecimal.new("0.0")
    self.lines.each do |ol|
      total += ol.price
    end
    return total    
  end
  
  def taxes
    taxes = BigDecimal.new("0.0")
    self.lines.each do |ol|
      taxes += ol.taxes
    end
    return taxes
  end

  # In future, incoming and outgoing directions could be handled by 'direction'
  def shipping_cost(direction = nil)
    return shipping_rate.total_cost
  end
  
  def shipping_taxes
    return shipping_rate.total_taxes
  end
  
  
  # Note that this shipping_rate is only here so that a shipping rate can be attached to 
  # a document. It does not actually return a ShippingRate object for this order, because
  # one order's products can come from any number of shipping partners and at any rates.
  # To get to a specific supplier's shipping rate object, you should rather do something like:
  # ShippingRate.find(document.suppliers.first.shipping_rate.id)
  def shipping_rate
    @sr ||= ShippingRate.new
    @sr.calculate_for(self)
    return @sr
  end
 
  def supplier_ids
    outgoing_supplier_ids
  end
  
  def incoming_supplier_ids
    return incoming_products_and_supply_items.collect(&:supplier_id).uniq
  end
  
  def outgoing_supplier_ids
    products.collect(&:supplier_id).uniq
  end
  
  def suppliers
    products.collect(&:supplier).uniq
  end
  
  def lines_by_supplier(supplier)
    supplier_lines = []
    lines.each do |line|
      supplier_lines << line if !line.product.blank? and line.product.supplier == supplier
    end
    return supplier_lines
  end
  
  
  # This returns only IDs of suppliers that have a matching entry in our database
  # It's a precaution for the ShippingRate calculation methods. This shouldn't be necessary
  # in a well-kept database where each product has an existing supplier.
  def existing_supplier_ids
    return supplier_ids & Supplier.all.collect(&:id)
  end
  
  def existing_incoming_supplier_ids
    return incoming_supplier_ids & Supplier.all.collect(&:id)
  end
  
  
  def products
    products = outgoing_products
  end
  
  def incoming_products_and_supply_items
    incoming_products = []
    outgoing_products.each do |p|
      if p.componentized?
        incoming_products << p.product_sets.collect(&:component)
      else
        incoming_products << p
      end
    end
    return incoming_products.flatten
  end
  
  def outgoing_products
    products = self.lines.collect(&:product)  
  end
  
  
  def weight
    weight = 0.0
    lines.each do |l|
      weight += l.quantity * l.product.weight unless l.product.weight.blank?
    end
    return weight
  end
  
  # Returns the quantity of a certain product or supply item as present in this order
  def quantity_of(product_or_supply_item)
    quantity = 0
    lines.each do |l|
      if l.product.componentized?
        l.product.product_sets.each do |ps|
          quantity = ps.quantity if ps.component == product_or_supply_item
        end
      else
        quantity = l.quantity if l.product == product_or_supply_item
      end
    end
    
    return quantity
  end
  
  def notification_email_addresses
    emails = []
    if self.billing_address.email.blank? and self.shipping_address.email.blank? and !self.user.nil?
      emails << self.user.email
    elsif self.shipping_address.nil? and !self.billing_address.email.blank?
      emails << self.billing_address.email
    else
      if (!self.user.nil? and !self.user.email.blank?)
        emails << self.user.email
      end
      emails << self.billing_address.email unless self.billing_address.email.blank?
      emails << self.shipping_address.email unless self.shipping_address.email.blank?
    end
    
    return emails.uniq
  end
  
  def direct_shipping?
    direct = true
    states = products.collect(&:direct_shipping).uniq
    # In future, raise exception when there is more than one supplier
    direct = false if (states.include?(false) or suppliers.count > 1)
    return direct
  end
  
  
  def contains_componentized_products?
    return products.collect(&:componentized?).uniq.include?(true)    
  end

  def live_update_products
    product_updates ||= []
    suppliers.each do |sup|
      if !sup.utility_class_name.blank?
        begin
          require "lib/#{sup.utility_class_name.underscore}"
          update_result = sup.utility_class_name.constantize.live_update(lines_by_supplier(sup))
          product_updates += update_result unless update_result.nil?
        rescue LoadError => e
          logger.error "Could not require lib/#{sup.utility_class_name.underscore} for live update: #{e.message}"
        end
      else
        logger.error "No utility_class_name set for supplier #{sup.name}. You must set one and write a live_update method inside that supplier's utility class if you want to use this feature."
      end
    end
    return product_updates
  end
  
end
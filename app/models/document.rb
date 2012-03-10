class Document < ActiveRecord::Base
  self.abstract_class = true


  def taxed_price
    return (products_taxed_price + total_taxed_shipping_price)
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

  # Note: This could be improved by having a ShippingCalculator dealing specifically with free shipping
  def shipping_cost(direction = nil)
    if self.qualifies_for_free_shipping?
      cost = BigDecimal.new("0.0")
    else
      sc = ShippingCalculator.get_default
      sc.calculate_for(self)
      cost = sc.cost
    end
    return cost
  end

  # Note: This could be improved by having a ShippingCalculator dealing specifically with free shipping
  def shipping_taxes
    if self.qualifies_for_free_shipping?
      cost = BigDecimal.new("0.0")
    else
      sc = ShippingCalculator.get_default
      sc.calculate_for(self)
      cost = sc.taxes
    end
    return cost
  end

  def total_taxes
    return (shipping_taxes + taxes)
  end

  def total_taxed_shipping_price
    return (shipping_cost + shipping_taxes)
  end

  def qualifies_for_free_shipping?
    qualifies = false
    begin
      minimum_item_count = ConfigurationItem.get("free_shipping_minimum_items").value.to_i
      qualifies = true if self.total_of_quantities >= minimum_item_count
    rescue ArgumentError
      # Can't find that configuration key, thus we do nothing, because the shipping rate's total_cost
      # will be returned in such cases
    end

    begin
      minimum_order_amount = BigDecimal.new(ConfigurationItem.get("free_shipping_minimum_amount").value)
      qualifies = true if self.products_taxed_price >= minimum_order_amount
    rescue ArgumentError
      # Can't find that configuration key, thus we do nothing, because the shipping rate's total_cost
      # will be returned in such cases
    end

    return qualifies
  end

  def total_of_quantities
    sum = 0
    lines.each {|l| sum += l.quantity}
    sum
  end

  def products
    products = self.lines.collect(&:product)
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


  def contains_componentized_products?
    return products.collect(&:componentized?).uniq.include?(true)
  end

  def live_update_products
    product_updates ||= []
    suppliers.each do |sup|
      if !sup.utility_class_name.blank?
        begin
          require Rails.root + "lib/#{sup.utility_class_name.underscore}"
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

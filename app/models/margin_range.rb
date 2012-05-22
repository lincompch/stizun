class MarginRange < ActiveRecord::Base
  
  belongs_to :supplier
  belongs_to :product
  after_save :recalculate_affected_products


  validate :cannot_be_for_supplier_and_product_simultaneously

  def self.system_wide_ranges
    MarginRange.where(:supplier_id => nil, :product_id => nil)
  end

  def self.percentage_for_price(price, ranges = nil)
    percentage = 5.0
    price = price.to_i
    ranges = MarginRange.where(:supplier_id => nil, :product_id => nil) if ranges.nil?
    range = ranges.where("start_price <= ? AND end_price >= ?", price, price).first
    if range.nil?
      range = ranges.where("start_price IS ? AND end_price IS ?", nil, nil).first 
    end
    percentage = range.margin_percentage unless range.nil?
    return percentage
  end

  def recalculate_affected_products
    unless self.product.nil?
      puts "saving #{self.product} due to product margin range change"
      self.product.reload.save
    end
    
    unless self.supplier.nil?
      Product.suspended_delta do
        self.supplier.products.each do |p|
          puts "saving #{p} due to supplier's margin range change"
          p.reload.save
        end
      end
    end

    if self.product.nil? and self.supplier.nil?
      unaffected_products = []
      unaffected_products << MarginRange.where("supplier_id IS NOT NULL").select{|mr| mr.supplier.products}
      unaffected_products << MarginRange.where("product_id IS NOT NULL").select{|mr| mr.product}
      affected_products = Product.all - unaffected_products
      Product.suspended_delta do
        affected_products.each do |p|
          puts "saving #{p} due to global margin range change"
          p.reload.save
        end
      end      
    end

  end

  def cannot_be_for_supplier_and_product_simultaneously
    unless product_id.blank? or supplier_id.blank?
      errors.add("MarginRange", "cannot be applied to suppliers and products at the same time. Only to one or none of them.")
    end
  end

end

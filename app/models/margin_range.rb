class MarginRange < ActiveRecord::Base
  
  belongs_to :supplier
  belongs_to :product
  #after_save :recalculate_affected_products


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

  def self.recalculate_recently_changed_products
    ranges_to_recalculate = MarginRange.where("recalculated_at IS NULL or recalculated_at < ?", DateTime.now - 30.minutes)
    ranges_to_recalculate = MarginRange.all.select{|mr|
      mr if mr.recalculated_at.nil? or ((mr.updated_at - mr.recalculated_at) < 2.hours) 

    }


    ranges_to_recalculate.each do |range|

      unless range.supplier.nil?
        Product.suspended_delta do
          range.supplier.products.each do |p|
            puts "saving #{p} due to supplier's margin range change"
            p.reload.save
          end
        end
        range.recalculated_at = DateTime.now
        range.save

        # This supplier is already taken care of now
        range.supplier.margin_ranges.each do |mr|
          mr.recalculated_at = DateTime.now
          ranges_to_recalculate.delete(mr) if mr.save
        end
      end

      unless range.product.nil?
        puts "saving #{range.product} due to product margin range change"
        range.product.reload.save
        range.recalculated_at = DateTime.now
        range.save        
      end
      
      if range.product.nil? and range.supplier.nil?
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
        range.recalculated_at = DateTime.now
        range.save
      end     

    end
  end

  def cannot_be_for_supplier_and_product_simultaneously
    unless product_id.blank? or supplier_id.blank?
      errors.add("MarginRange", "cannot be applied to suppliers and products at the same time. Only to one or none of them.")
    end
  end

end

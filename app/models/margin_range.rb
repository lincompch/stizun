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
    price = price.to_f.round(5)
    ranges = MarginRange.where(:supplier_id => nil, :product_id => nil) if ranges.nil?
    range = ranges.where("start_price <= ? AND end_price >= ?", price, price).first
    if range.nil?
      range = ranges.where("start_price IS ? AND end_price IS ?", nil, nil).first 
    end

    unless range.nil?
      if range.margin_percentage.nil?
        if (!range.band_minimum.nil? and !range.band_maximum.nil?)
          percentage = (price - range.start_price) / (range.end_price - range.start_price) * (range.band_maximum - range.band_minimum) + range.band_minimum
        end
      else
        percentage = range.margin_percentage
      end
    end
    return percentage
  end

  def self.recalculate_recently_changed_products

    time_window = 24.hours
    recently_udpated = MarginRange.all.select{|mr| mr if mr.updated_at > DateTime.now - time_window}

    Product.suspended_delta do
      Product.available.each do |p|

        unless p.margin_ranges.empty?
          # At least one of the product's ranges is included in the range that was recently updated
          if !(p.margin_ranges & recently_udpated).empty?
            puts "Saving #{p.to_s} due to a product-specific margin range change."
            p.save
          end
        end

        unless p.supplier.nil? or p.supplier.margin_ranges.empty?
          if !(p.supplier.margin_ranges & recently_udpated).empty?
            puts "Saving #{p.to_s} due to a supplier-specific margin range change."
            p.save
          end
        end

        # There are no supplier- or product-specific ranges for this product, so consider the global ones
        if (p.supplier.nil? or p.supplier.margin_ranges.empty?) and p.margin_ranges.empty?
          if !(MarginRange.system_wide_ranges & recently_udpated).empty?
            puts "Saving #{p.to_s} due to a system-wide margin range change."
            p.save
          end
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

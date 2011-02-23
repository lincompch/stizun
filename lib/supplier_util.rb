class SupplierUtil

# Synchronize all supply items from a supplier's provided CSV file
  def import_supply_items(filename = self.import_filename)
    
    # before calling this in a descended class, you must set up these variables:
    # TODO
    
    SupplyItem.suspended_delta do
        
      received_codes = []
      @fcsv.each do |sp|
        # Keep track of which products we received, so we can later determine which ones
        # we are stocking but shouldn't be stocking anymore
        received_codes << sp[@field_names[:supplier_product_code]]
        # check if we have product too
        local_supply_item = SupplyItem.where(:supplier_id => @supplier.id, 
                                             :supplier_product_code => sp[@field_names[:supplier_product_code]]).first
        
        # We do not have that supply item yet
        if local_supply_item.nil?
          si = SupplierUtil.supply_item_from_csv_row(@supplier, sp, @field_names)
          
          if si.save
            History.add("Supply item added during sync: #{si.to_s}", History::SUPPLY_ITEM_CHANGE, si)
          else
            History.add("Failed adding supply item during sync: #{si.inspect.to_s}, #{si.errors.to_s}", History::SUPPLY_ITEM_CHANGE, si)
          end
        
        # We already have that supply item and need to update supply item
        # and related product information
        else
          overwrite_field(local_supply_item, "purchase_price", sp[@field_names[:price_excluding_vat]].to_s)
          overwrite_field(local_supply_item, "stock", sp[@field_names[:stock_level]].gsub("'","").to_i)
          overwrite_field(local_supply_item, "manufacturer_product_code", sp[@field_names[:manufacturer_product_code]])
          populate_field(local_supply_item, "category01", sp[@field_names[:category01]])
          populate_field(local_supply_item, "category02", sp[@field_names[:category02]])
          populate_field(local_supply_item, "category03", sp[@field_names[:category03]])
          local_supply_item.save
        end
      end
      
      # Find out which items we need to delete locally
      total_codes = @supplier \
                    .supply_items \
                    .collect(&:supplier_product_code)
      to_delete = total_codes - received_codes
      to_delete.each do |td|
        supply_item = SupplyItem.find_by_supplier_product_code(td)
        
        supply_item.status_constant = SupplyItem::DELETED
        supply_item.save
        History.add("Marked Supply Item with supplier code #{td} as deleted", History::SUPPLY_ITEM_CHANGE)
      end
    end
  end
  
  def overwrite_field(item, field, data)
    unless (data.blank? or data == item.send(field))
      if item.update_attributes(:"#{field}" => data)
        History.add("Supply item change: #{item.to_s}: #{field} = #{data}", History::SUPPLY_ITEM_CHANGE, item)
      else
        History.add("Supply item change FAILED: #{item.to_s}: #{field} = #{data}. Errors: #{item.errors.full_messages}", History::SUPPLY_ITEM_CHANGE, item)
      end
    end
  end
  
  def populate_field(item, field, data)
    overwrite_field(item, field, data) if item.send(field).blank?
  end

  
  def self.supply_item_from_csv_row(supplier, row, field_names)
    require 'iconv'
 
    si = supplier.supply_items.new
    si.supplier_product_code = row[field_names[:supplier_product_code]]
    si.name = "#{row[field_names[:name01]].gsub("ß","ss")}" 
    si.name += " #{row[field_names[:name02]].to_s.gsub("ß","ss")}" unless field_names[:name02].blank?
    si.name += " (#{row[field_names[:name03]].to_s.gsub("ß","ss")})" unless field_names[:name03].blank?
    
    si.name = Iconv.conv('utf-8', 'iso-8859-1', si.name)
    si.name = si.name.strip
    
    si.manufacturer = "#{row[field_names[:manufacturer]]}"
    si.manufacturer = Iconv.conv('utf-8', 'iso-8859-1', si.manufacturer)
    
    si.product_link = "#{row[field_names[:product_link]]}"
    si.pdf_url= "#{row[field_names[:pdf_url]]}"
    
    si.weight = row[field_names[:weight]].gsub(",",".").to_f
    si.manufacturer_product_code = "#{row[field_names[:manufacturer_product_code]]}"
    
    si.description = "#{row[field_names[:description01]].gsub("ß","ss")}"
    si.description += "#{row[field_names[:description02]].to_s.gsub("ß","ss")}" unless field_names[:description02].blank? 
    si.description = Iconv.conv('utf-8', 'iso-8859-1', si.description)
    si.description = si.description.strip
    
    si.purchase_price = BigDecimal.new(row[field_names[:price_excluding_vat]].to_s.gsub(",","."))
    # TODO: Read actual tax percentage from import file and create class as needed
    si.tax_class = TaxClass.find_by_percentage(8.0) or TaxClass.first
    si.stock = row[field_names[:stock_level]].gsub("'","").to_i
    
    si.image_url = "#{row[field_names[:image_url]]}" unless field_names[:image_url].blank?
    
    si.category01 = "#{row[field_names[:category01]]}"
    si.category02 = "#{row[field_names[:category02]]}" 
    si.category03 = "#{row[field_names[:category03]]}"
    
    return si
  end
  
end
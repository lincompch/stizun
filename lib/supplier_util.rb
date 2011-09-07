# encoding: utf-8

class SupplierUtil
  
  def supplier_logger
    @supplier_logger ||= Logger.new("#{Rails.root}/log/supplier_import_#{DateTime.now.to_s.gsub(":","-")}.log")
  end
  
# Synchronize all supply items from a supplier's provided CSV file
  def import_supply_items(filename = self.import_filename)
    require 'iconv'

    # before calling this in a descended class, you must set up these variables:
    # TODO
    root_category = @supplier.category
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
            supplier_logger.info("[#{DateTime.now.to_s}] SupplyItem create: #{si.inspect}")
            #History.add("Supply item added during sync: #{si.to_s}", History::SUPPLY_ITEM_CHANGE, si)
          else
            supplier_logger.error("Failed adding supply item during sync: #{si.inspect.to_s}, #{si.errors.to_s}")
            History.add("Failed adding supply item during sync: #{si.inspect.to_s}, #{si.errors.to_s}", History::SUPPLY_ITEM_CHANGE, si)
          end
        
        # We already have that supply item and need to update supply item
        # and related product information
        else
          overwrite_field(local_supply_item, "purchase_price", sp[@field_names[:price_excluding_vat]].to_s) unless sp[@field_names[:price_excluding_vat]].to_f == 0
          overwrite_field(local_supply_item, "stock", sp[@field_names[:stock_level]].gsub("'","").to_i)
          overwrite_field(local_supply_item, "manufacturer", Iconv.conv('utf-8', 'iso-8859-1', sp[@field_names[:manufacturer]]))
          overwrite_field(local_supply_item, "manufacturer_product_code", sp[@field_names[:manufacturer_product_code]])
          overwrite_field(local_supply_item, "category01", "#{Iconv.conv('utf-8', 'iso-8859-1', sp[@field_names[:category01]])}")
          overwrite_field(local_supply_item, "category02", "#{Iconv.conv('utf-8', 'iso-8859-1', sp[@field_names[:category02]])}")
          overwrite_field(local_supply_item, "category03", "#{Iconv.conv('utf-8', 'iso-8859-1', sp[@field_names[:category03]])}")
          overwrite_field(local_supply_item, "category_id", root_category.category_from_csv("#{Iconv.conv('utf-8', 'iso-8859-1', sp[@field_names[:category01]])}",
              "#{Iconv.conv('utf-8', 'iso-8859-1', sp[@field_names[:category02]])}", 
              "#{Iconv.conv('utf-8', 'iso-8859-1', sp[@field_names[:category03]])}"))
          unless local_supply_item.changes.empty?
            changes = local_supply_item.changes
            if local_supply_item.save
              supplier_logger.info("[#{DateTime.now.to_s}] SupplyItem change: #{local_supply_item.to_s}:  #{changes.inspect}")
              #History.add("Supply item change: #{local_supply_item.to_s}: #{changes.inspect}", History::SUPPLY_ITEM_CHANGE, local_supply_item)
            else
              History.add("Supply item change FAILED: #{local_supply_item.to_s}: #{local_supply_item.changes.inspect}. Errors: #{local_supply_item.errors.full_messages}", History::SUPPLY_ITEM_CHANGE, local_supply_item)
            end
          else
            supplier_logger.info("[#{DateTime.now.to_s}] SupplyItem identical, thus not changed: #{local_supply_item.to_s}")
          end
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
    # Find out which categories are empty, and remove them from supplier's category tree
    root_category.children_categories.flatten.each do |category|
      if category.children.blank? && category.supply_items.empty? # LEAF with no supply_items
        remove_category(category)
      end
    end
  end
  
  # Using recursion to find categories with no supply items and remove them
  def remove_category(category)
    if category.parent.children.count == 1
      remove_category(category.parent)
      category.delete
    else
      category.delete if category.children.count == 1
      return
    end
  end
  
  def overwrite_field(item, field, data)
    unless (data.blank? or data == item.send(field))
      item.send "#{field}=", data
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
    
    si.description = "#{row[field_names[:description01]].to_s.gsub("ß","ss")}"
    si.description += "#{row[field_names[:description02]].to_s.gsub("ß","ss")}" unless field_names[:description02].blank? 
    si.description = Iconv.conv('utf-8', 'iso-8859-1', si.description)
    si.description = si.description.strip
    
    si.purchase_price = BigDecimal.new(row[field_names[:price_excluding_vat]].to_s.gsub(",","."))
    # TODO: Read actual tax percentage from import file and create class as needed
    si.tax_class = TaxClass.find_by_percentage(8.0) or TaxClass.first
    si.stock = row[field_names[:stock_level]].gsub("'","").to_i
    
    si.image_url = "#{row[field_names[:image_url]]}" unless field_names[:image_url].blank?

    si.category01 = "#{Iconv.conv('utf-8', 'iso-8859-1', row[field_names[:category01]])}"
    si.category02 = "#{Iconv.conv('utf-8', 'iso-8859-1', row[field_names[:category02]])}" 
    si.category03 = "#{Iconv.conv('utf-8', 'iso-8859-1', row[field_names[:category03]])}"

    si.category_id = supplier.category.category_from_csv("#{Iconv.conv('utf-8', 'iso-8859-1', row[field_names[:category01]])}",
              "#{Iconv.conv('utf-8', 'iso-8859-1', row[field_names[:category02]])}", 
              "#{Iconv.conv('utf-8', 'iso-8859-1', row[field_names[:category03]])}")
    return si
  end
  
  def self.create_category_tree(supplier, file_name)
    require 'iconv'
    category = supplier.category
    category_string = `#{category_string_cmd(file_name)}`
    category_string = Iconv.conv('utf-8', 'iso-8859-1', category_string)
    category_string.split("\n").each do |line|
      categories = line.split("\t")
  
      unless categories[0].blank?
        category.reload
        root = category.find_or_create_by_name("#{Iconv.conv('utf-8', 'iso-8859-1', categories[0])}", 1, supplier)
        root.save
      end
      
      unless categories[1].blank?
        category.reload
        level2 = category.find_or_create_by_name("#{Iconv.conv('utf-8', 'iso-8859-1', categories[1])}", 2, supplier)
        level2.parent = root
        level2.save
      end             

      unless categories[2].blank?
        category.reload
        level3 = category.find_or_create_by_name("#{Iconv.conv('utf-8', 'iso-8859-1', categories[2] )}", 3, supplier)
        level3.parent = level2
        level3.save
      end        
    end
    category.reload
  end
  


  # If you want to implement a live update method for your own supplier util, subclass this class and override
  # live_update to return a changes hash like ActiveRecord does.
  def live_update
    return nil
  end
  
end

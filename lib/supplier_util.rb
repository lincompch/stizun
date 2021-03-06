# encoding: utf-8
class SupplierUtil

  def supplier_logger #@supplier_logger ||= Logger.new("#{Rails.root}/log/supplier_import_#{DateTime.now.to_s.gsub(":","-")}.log")
    # The above appears to break in production when using Delayed::Job because it can't get to the directory. So hardcoding here.
    #if File.exists?("/home/lincomp/production/current/log")
    @supplier_logger ||= Logger.new(Rails.root + "log/supplier_import_#{DateTime.now.to_s.gsub(":","-")}.log")
    #else
    #  @supplier_logger ||= Logger.new("/tmp/supplier_import_#{DateTime.now.to_s.gsub(":","-")}.log")
    #end
  end

  def parse_line(line)
    data = {}
    line_array = line.split(@csv_parse_options[:col_sep])

    unless @expected_csv_field_count.nil?
      broken_line = true if line_array.count < @expected_csv_field_count # This line is invalid, we don't want it
    end

    if broken_line == true
      return false
    else
      @field_mapping.each do |k,v|
        value = v.nil? ? nil : line_array[v]
        unless value.nil? or @csv_parse_options[:quote_char].nil?
          result = value.match(/^#{@csv_parse_options[:quote_char]}(.*)#{@csv_parse_options[:quote_char]}/)
          value = result[1] unless result.nil?
          # Unescape the double-quote-char escapes in this special case
          if @csv_parse_options[:quote_char] == '"'
            value.gsub!('""','"')
          end
        end
        data[k] = value
      end
      return data
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

  def update_supply_item(supply_item, data)
    normalized_price = calculate_price(data)
    overwrite_field(supply_item, "description", construct_supply_item_description(data))
    overwrite_field(supply_item, "purchase_price", normalized_price) unless normalized_price.to_f == 0.0
    overwrite_field(supply_item, "stock", data[:stock_level].gsub("'","").to_i)
    overwrite_field(supply_item, "weight", data[:weight].gsub(",",".").to_f)
    overwrite_field(supply_item, "manufacturer", data[:manufacturer])
    overwrite_field(supply_item, "manufacturer_product_code", data[:manufacturer_product_code])
    overwrite_field(supply_item, "image_url", "#{data[:image_url]}")
    overwrite_field(supply_item, "pdf_url", "#{data[:pdf_url]}")
    overwrite_field(supply_item, "category01", "#{data[:category01]}")
    overwrite_field(supply_item, "category02", "#{data[:category02]}")
    overwrite_field(supply_item, "category03", "#{data[:category03]}")
    overwrite_field(supply_item, "ean_code", "#{data[:ean_code]}")

    unless supply_item.changes.empty?
      changes = supply_item.changes
      if supply_item.save
        supplier_logger.info("[#{DateTime.now.to_s}] SupplyItem change: #{supply_item.to_s}:  #{changes.inspect}")
      else
        supplier_logger.error("[#{DateTime.now.to_s}] Supply item change FAILED: #{supply_item.to_s}: #{supply_item.changes.inspect}. Errors: #{supply_item.errors.full_messages}")
      end
    else
      supplier_logger.info("[#{DateTime.now.to_s}] SupplyItem identical, thus not changed: #{supply_item.to_s}")
    end
  end


  # Goes through the existing supply items in the system, then tries to find each
  # of them in the supplier CSV file. If that fails, the item is marked as deleted locally.
  # If the item is there, we read the updated product information from the CSV file and update the
  # supply item and its related products.
  def update_supply_items(filename = self.import_filename)
    # Hack: First get rid of all ProductSets that don't have any live components anymore, otherwise
    # updates will fail on calculating the weight
    ProductSet.cleanup
    available_supplier_product_codes = @supplier.supply_items.available.collect(&:supplier_product_code)
    to_delete = available_supplier_product_codes.dup

    deleted_supplier_product_codes = @supplier.supply_items.deleted.collect(&:supplier_product_code)
    to_reactivate = []

    item_hashes = []


    file = File.open(filename, "r")
    file.each do |line|
      data = parse_line(line)
      next if data == false # The array isn't there, skip this line
      next if data[:supplier_product_code].blank? # The line is incomplete, skip it
      if available_supplier_product_codes.include?(data[:supplier_product_code])
        item_hashes << data
        to_delete -= [data[:supplier_product_code]] # Remove those items that were actually found, so we can delete the rest
      end
      if deleted_supplier_product_codes.include?(data[:supplier_product_code])
        item_hashes << data
        to_reactivate += [data[:supplier_product_code]]
      end
    end
    file.close

    SupplyItem.expire_category_tree_cache(@supplier)
    # Update the local supply item's information using the line from the CSV file

    ThinkingSphinx::Deltas.suspend :supply_item do
      # Deactivate the supply item if the line's not there anymore
      to_delete.each do |td|
        supply_item = @supplier.supply_items.where(:supplier_product_code => td).first
        unless supply_item.nil?
          supply_item.status_constant = SupplyItem::DELETED
          if supply_item.save
            supplier_logger.info("[#{DateTime.now.to_s}] Marked Supply Item as deleted: #{supply_item.to_s}")
          else
            supplier_logger.info("[#{DateTime.now.to_s}] Could not mark Supply Item as deleted: #{supply_item.to_s}: #{supply_item.errors.full_messages}")
          end
        end
      end

      # Deactivate the supply item if the line's not there anymore
      to_reactivate.each do |td|
        supply_item = @supplier.supply_items.where(:supplier_product_code => td).first
        unless supply_item.nil?
          supply_item.status_constant = SupplyItem::AVAILABLE
          if supply_item.save
            supplier_logger.info("[#{DateTime.now.to_s}] Reactivated supply item because it reappared in the CSV file: #{supply_item.to_s}")
          else
            supplier_logger.info("[#{DateTime.now.to_s}] Could not reactivate supply item: #{supply_item.to_s}: #{supply_item.errors.full_messages}")
          end
        end
      end

      item_hashes.each do |data|
        supply_item = @supplier.supply_items.where(:supplier_product_code => data[:supplier_product_code]).first
        update_supply_item(supply_item, data)
      end
    end
    Product.update_price_and_stock # Sync available products to the now changed supply items
  end

  # The updates array needs to be in the form [ [supplier_product_code1, stock_level],
  #                                             [supplier_product_code2, stock_level]]
  # The updates array must be set up in a method in the descending class (e.g. AlltronUtil)
  def quick_update_stock(filename)
    ThinkingSphinx::Deltas.suspend :supply_item do
      @updates.each do |upd|
        si = @supplier.supply_items.where(:supplier_product_code => upd[0]).first
        unless si.nil?
          if si.update_attributes(:stock => upd[1]) == true
            supplier_logger.info("[#{DateTime.now.to_s}] Quick stock update: #{si.to_s} now #{si.stock}")
          else
            supplier_logger.error("[#{DateTime.now.to_s}] Quick stock update failed: #{si.to_s}, errors:  #{si.errors.full_messages}")
          end
        end
      end
    end
    Product.update_price_and_stock # Sync available products to the now changed supply items
  end


  # Import supply items from a supplier-provided CSV file, but only if they're
  # not present in our system yet.
  def import_supply_items(filename = self.import_filename)
    # before calling this in a descended class, you must set up these variables:
    # @supplier = The supplier to import for (an AR object)
    SupplyItem.expire_category_tree_cache(@supplier)

    ThinkingSphinx::Deltas.suspend :supply_item do
      File.open(filename, "r:utf-8").each_with_index do |line, i|
        next if i == 0 # We skip the first line, it only contains header information
        data = parse_line(line)
        next if data == false
        next if data[:supplier_product_code].blank? # The line is incomplete, skip it
        # check if we have the supply item
        local_supply_item = SupplyItem.where(:supplier_id => @supplier.id,
                                             :supplier_product_code => data[:supplier_product_code]).first
        # We do not have that supply item yet
        if local_supply_item.nil?
          si = new_supply_item(data)
          if si.save
            supplier_logger.info("[#{DateTime.now.to_s}] SupplyItem create: #{si.inspect}")
          else
            supplier_logger.error("Failed adding supply item during sync: #{si.inspect.to_s}, #{si.errors.to_s}")
          end
        # We already have that supply item and need to update that and related product information
        else
          update_supply_item(local_supply_item, data)
        end
      end
    end
    Product.update_price_and_stock # Sync available products to the now changed supply items
    CategoryDispatcher.create_unique_combinations_for(@supplier)
  end

  def calculate_price(data)
    price = BigDecimal.new("0.0")
    if data[:price_excluding_vat] and data[:additional_cost]
      price = sanitize_price(data[:price_excluding_vat].to_s) + sanitize_price(data[:additional_cost].to_s)
    elsif data[:price_excluding_vat]
      price = sanitize_price(data[:price_excluding_vat].to_s)
    end
    return BigDecimal.new(price)
  end

  def sanitize_price(price_string)
    return BigDecimal.new(price_string.gsub(",",".").gsub("'",""))
  end

  # Take all the raw data about a supply item and return a nice, meaningful string for its name, which can
  # be different between suppliers and is therefore handled in the supplier-specific subclasses
  def construct_supply_item_name(data)
    @supply_item_name = @supply_item_name.strip
    @supply_item_name = @supply_item_name.gsub("ß","ss")
    return @supply_item_name
  end

  # Take all the raw data about a supply item and return a nice, meaningful string for its description, which can
  # be different between suppliers and is therefore handled in the supplier-specific subclasses
  def construct_supply_item_description(data)
    @description = @description.strip
    @description = @description.gsub("ß","ss")
    return @description
  end

  def new_supply_item(data)
    # Maybe takes more memory than below
    #si = @supplier.supply_items.new
    si = SupplyItem.new
    si.supplier = @supplier
    si.name = construct_supply_item_name(data)
    si.description = construct_supply_item_description(data)
    si.supplier_product_code = data[:supplier_product_code]
    si.ean_code = "" # Use a blank code as default
    si.ean_code = data[:ean_code] unless data[:ean_code].blank?
    si.manufacturer = "#{data[:manufacturer]}" unless data[:manufacturer].blank?
    si.product_link = "#{data[:product_link]}" unless data[:product_link].blank?
    si.pdf_url= "#{data[:pdf_url]}"
    if data[:weight].nil?
      si.weight = 0.0
    else
      si.weight = data[:weight].gsub(",",".").to_f
    end
    si.manufacturer_product_code = "#{data[:manufacturer_product_code]}"
    si.purchase_price = calculate_price(data)
    si.stock = data[:stock_level].gsub("'","").to_i unless data[:stock_level].nil?
    si.image_url = "#{data[:image_url].strip}" unless data[:image_url].blank?
    si.description_url = "#{data[:description_url].strip}" unless data[:description_url].blank?
    si.category01 = "#{data[:category01]}"
    si.category02 = "#{data[:category02]}"
    si.category03 = "#{data[:category03]}"
    return si
  end

  # If you want to implement a live update method for your own supplier util, subclass this class and override
  # live_update to return an array of change hashes like ActiveRecord uses them.
  def self.live_update(object)
    return nil
  end

  # Return a safe, sanitized product description (HTML or text). Apply any transformations, special retrieval,
  # any type of data mangling in a method inside the supplier-specific subclass.
  def self.get_product_description_from_url(url)
    return nil
  end

end

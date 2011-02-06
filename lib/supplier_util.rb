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
          si= SupplyItem.new_from_csv_record(sp)
          
          if si.save
            History.add("Supply item added during sync: #{si.to_s}", History::SUPPLY_ITEM_CHANGE, si)
          else
            History.add("Failed adding supply item during sync: #{si.inspect.to_s}, #{si.errors.to_s}", History::SUPPLY_ITEM_CHANGE, si)
          end
        
        # We already have that supply item and need to update supply item
        # and related product information
        else
          if local_supply_item.purchase_price != BigDecimal(sp[@field_names[:price_excluding_vat]].to_s)
            old_price = local_supply_item.purchase_price
            local_supply_item.purchase_price = BigDecimal(sp[@field_names[:price_excluding_vat]].to_s)
            local_supply_item.save
            History.add("Changed price for #{local_supply_item.to_s} from #{old_price} to #{local_supply_item.purchase_price}", History::SUPPLY_ITEM_CHANGE, local_supply_item)
          end
          
          if local_supply_item.stock != sp[@field_names[:stock_level]].gsub("'","").to_i
            old_stock = local_supply_item.stock
            local_supply_item.stock = sp[@field_names[:stock_level]].gsub("'","").to_i
            local_supply_item.save
            History.add("Changed stock for #{local_supply_item.to_s} from #{old_stock} to #{local_supply_item.stock}", History::SUPPLY_ITEM_CHANGE, local_supply_item)
          end

          # Adapt the manufacturer product code in any case
          local_supply_item.manufacturer_product_code = "#{sp[@field_names[:manufacturer_product_code]]}"
          local_supply_item.save
          History.add("Changed manufacturer number for #{local_supply_item.to_s} to #{sp[@field_names[:manufacturer_product_code]]}", History::SUPPLY_ITEM_CHANGE, local_supply_item)
          
          
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

end
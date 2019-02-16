#    (0.1ms)  SELECT COUNT(*) FROM `supply_items`
# => 669485




def prettycats(cats)
    cats.collect {|cat| cat.name }.join(',')
end

def prettycd(cd)
    "#{cd[:level_01]} : #{cd[:level_02]} : #{cd[:level_03]} -> #{prettycats(cd.categories)}"
end


ThinkingSphinx::Deltas.suspend :supply_item do
    SupplyItem.deleted.each do |sup|
        sdeletelog.puts(sup) if sup.destroy
    end
end

pdeletelog = File.open("/tmp/delete_products_log.txt", "w+")
sdeletelog = File.open("/tmp/delete_supply_items_log.txt", "w+")

ThinkingSphinx::Deltas.suspend :product do
    ThinkingSphinx::Deltas.suspend :supply_item do
        Product.having_unavailable_supply_item.each do |prod|
            #if !SupplyItem.exists?(prod.supply_item_id) \
            if prod.supply_item \
            &&prod.document_lines.empty? \
            && prod.static_document_lines.empty?
            sdeletelog.puts(prod.supply_item) if prod.supply_item.destroy
            pdeletelog.puts(prod) if prod.destroy
            end
        end
    end
end

pdeletelog.close
sdeletelog.close

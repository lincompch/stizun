module Admin::SupplyItemsHelper

  def category_id_select_tag_for_supplier(supplier, selected)
    cache_key = "supplier_#{supplier.id}_categories_sorted"

    sorted_categories = Rails.cache.read(cache_key)
    if sorted_categories.nil?
        sorted_categories = Category.where(:supplier_id => supplier).sort { |a,b| a.fully_qualified_name <=> b.fully_qualified_name }
        Rails.cache.write(cache_key, sorted_categories)
    end

    cached_select = Rails.cache.fetch("#{supplier.id}_select_tag") do
      select_tag :category_id,
        options_from_collection_for_select(sorted_categories,
        :id, :fully_qualified_name, selected),
        {:include_blank => true}
    end
    cached_select.gsub(/value="#{selected}"/, "selected=\"selected\" value=\"#{selected.to_i}\"")
  end


  def extended_status_links(item)
    links_html = ""

    if item.product.nil?
      product = Product.available.where(:manufacturer_product_code => item.manufacturer_product_code).first
      if product
        links_html += "[#{link_to 'HAS PRODUCT', edit_admin_product_path(product), :class => 'fancybox'}] "
      end      
    else  
      links_html += "[#{link_to 'IS PRODUCT', edit_admin_product_path(item.product), :class => 'fancybox'}] "     
      links_html += item.product.cheaper_supply_item_available? ? "[#{link_to 'CHEAPER SIs', switch_to_cheaper_supply_item_admin_product_path(item.product)}] " : "[CHEAPEST SI] "
    end

    return links_html.html_safe
  end

end


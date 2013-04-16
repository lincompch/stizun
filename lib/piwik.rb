  def piwik_ecommerce_item(sku, name = nil, category = nil, price = 0.0, qty = 0)
    if category.is_a?(Array)
      category = category[0..4].as_json.to_s.gsub("\"","'")
    else
      category = "'#{category}'"
    end

    js =  "_paq.push(['addEcommerceItem',"
    js += "'#{sku}', " # (required) SKU: Product unique identifier
    js += "'#{name}', " # (optional) Product name
    js += "#{category}, " # (optional) Product category. You can also specify an array of up to 5 categories eg. ["Books", "New releases", "Biography"]
    js += "#{price.to_f}, " # (recommended) Product price
    js += "#{qty.to_i}" # (optional, default to 1) Product quantity
    js += "]);\n"
    return js
  end

  def piwik_ecommerce_order(order_id, grand_total, total_without_shipping, taxes, shipping)
    js =  "_paq.push(['trackEcommerceOrder', "
    js += "'#{order_id}', "
    js += "#{grand_total.to_f}, " 
    js += "#{total_without_shipping.to_f}, " 
    js += "#{taxes.to_f}, " 
    js += "#{shipping.to_f}, " 
    js += "false" 
    js += "]);\n"
    return js
  end

  def piwik_track_ecommerce_cart_update(cart_amount)
    js = "_paq.push(['trackEcommerceCartUpdate', "
    js += "#{cart_amount.to_f}]);\n"
    return js
  end

  def piwik_set_ecommerce_view(sku, name, category, price)
    if category.is_a?(Array)
      category = category[0..4].as_json.to_s.gsub("\"","'")
    else
      category = "'#{category}'"
    end

    js =  "_paq.push(['setEcommerceView',"
    js += "'#{sku}', " # (required) SKU: Product unique identifier
    js += "'#{name}', " # (optional) Product name
    js += "#{category}, " # (optional) Product category. You can also specify an array of up to 5 categories eg. ["Books", "New releases", "Biography"]
    js += "#{price.to_f}" # (recommended) Product price
    js += "]);\n"
    return js
  end

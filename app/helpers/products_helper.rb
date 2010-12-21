module ProductsHelper
  
  
  def product_rounded_price(product)
    if product.on_sale?
      
      # This replicates the behavior found in the Product model: Percentage rebate
      # overrides absolute rebate
      if product.absolute_rebate?
        rebate_string = product.absolute_rebate
      elsif product.percentage_rebate?
        rebate_string = product.percentage_rebate.to_s + "%"
      end
      
      "<span class='sales_price'>#{pretty_price(product.taxed_price.rounded)}<span> (You save: #{rebate_string})"
    else
      pretty_price(product.taxed_price.rounded)
    end
      
  end
 
  def pretty_margin(product)
    if (product.purchase_price > 0 and product.margin > 0)
      if product.componentized?
        percent_string = product.calculated_margin_percentage.round(3).to_s
      else
        percent_string = ((100/product.purchase_price) * product.margin).round(3).to_s
      end
      
       string = sprintf "%.2f", product.margin
       pretty_margin = percent_string + "% = " + string
    else
      return sprintf "%.2f", 0
    end
  end
  
  def pretty_taxes(product)
    string = sprintf "%.2f", product.taxes
    product.tax_class.percentage.round(3).to_s + "% = " + string
  end
  
  
  
end

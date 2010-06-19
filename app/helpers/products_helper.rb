module ProductsHelper
  
  
  def product_rounded_price(product)
    if product.on_sale?
      
      # This replicates the behavior found in the Product model: Percentage rebate
      # overrides absolute rebate
      if product.absolute_rebate > 0
        rebate_string = product.absolute_rebate
      end
      
      if product.percentage_rebate > 0
        rebate_string = product.percentage_rebate.to_s + "%"
      end
      
      "<span class='sales_price'> #{pretty_price(product.rounded_price)}<span> (You save: #{rebate_string})"
    else
      pretty_price(product.rounded_price)
    end
      
  end
end

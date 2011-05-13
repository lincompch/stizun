
# prod[] is hash generated from a Cucumber table, e.g.
# table.hashes.each do |prod|; foo; end
def create_product(prod)

    purchase_price = BigDecimal.new("0.0")
    purchase_price = BigDecimal.new(prod['purchase_price'].to_s) unless prod['purchase_price'].nil?
    margin_percentage = BigDecimal.new("0.0")
    margin_percentage = prod['margin_percentage'].to_f unless prod['margin_percentage'].nil?
    sales_price = nil
    sales_price = BigDecimal.new(prod['sales_price']) unless prod['sales_price'].nil?
    direct_shipping = false
    direct_shipping = true if prod['direct_shipping'] == "true"
    weight = 0
    weight = prod['weight'].to_f unless prod['weight'].nil?


    tax_class = TaxClass.where(:percentage => prod['tax_percentage']).first unless prod['tax_percentage'].blank?
    if tax_class.nil?
      tax_class = TaxClass.create(:percentage => 8.0, :name => "8.0")
    end

    prod['description'].blank? ? description = "No description" : description = prod['description']
    
    supplier = Supplier.find_by_name(prod['supplier'])
    product = Product.create(:name => prod['name'],
                             :description => description,
                             :weight => weight,
                             :sales_price => sales_price,
                             :supplier => supplier,
                             :tax_class => tax_class,
                             :purchase_price => purchase_price,
                             :margin_percentage => margin_percentage,
                             :direct_shipping => direct_shipping)
  if prod['category']
    category = Category.where(:name => prod['category']).first
    category = Category.create(:name => prod['category']) if category.nil?
    product.categories << category
    product.save
  end
  
  return product
end
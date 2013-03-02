
# prod[] is hash generated from a Cucumber table, e.g.
# table.hashes.each do |prod|; foo; end
def create_product(prod)

    purchase_price = BigDecimal.new("0.0")
    purchase_price = BigDecimal.new(prod['purchase_price'].to_s) unless prod['purchase_price'].nil?
    sales_price = nil
    sales_price = BigDecimal.new(prod['sales_price']) unless prod['sales_price'].nil?
    weight = 0
    weight = prod['weight'].to_f unless prod['weight'].nil?
    manufacturer_product_code = prod['manufacturer_product_code']

    tax_percentage = prod['tax_percentage'] || 8.0
    tax_class = TaxClass.where(:percentage => tax_percentage).first unless tax_percentage.nil?
    if tax_class.nil?
      tax_class = TaxClass.create(:percentage => 8.0, :name => "8.0")
    end

    prod['description'].blank? ? description = "No description" : description = prod['description']
    
    is_featured = false
    is_featured = true if ["yes", "true", "1"].include?(prod['featured'])
    is_visible = true
    is_visible = false if ["no", "false", "0"].include?(prod['visible'])
    
    supplier = Supplier.find_by_name(prod['supplier'])

    product = Product.where(:name => prod['name'],
                             :description => description,
                             :weight => weight,
                             :sales_price => sales_price,
                             :supplier_id => supplier,
                             :tax_class_id => tax_class,
                             :purchase_price => purchase_price,
                             :manufacturer_product_code => manufacturer_product_code,
                             :is_featured => is_featured,
                             :is_visible => is_visible).first
    if product.nil?
      product = Product.create(:name => prod['name'],
                               :description => description,
                               :weight => weight,
                               :sales_price => sales_price,
                               :supplier => supplier,
                               :tax_class => tax_class,
                               :purchase_price => purchase_price,
                               :manufacturer_product_code => manufacturer_product_code,
                               :is_featured => is_featured,
                               :is_visible => is_visible)
    end
  if prod['category']
    category = Category.where(:name => prod['category']).first
    category = Category.create(:name => prod['category']) if category.nil?
    product.categories << category
    product.save
  end


  # Ugly, but at least it makes test authors know what went wrong
  if product.errors.empty?
    return product
  else
    puts "Errors creating product: #{product.errors.full_messages}"
    return false
  end
end

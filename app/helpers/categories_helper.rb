module CategoriesHelper
  
  def categories_breadcrumb_path(current, linked = false)
    if linked == true
      links = []
      current.ancestor_chain.each do |category|
        links << link_to(category.name, category_products_path(category))
      end
      links.join(" >> ").html_safe
    else
      current.ancestor_chain.collect(&:name).join(" >> ")
    end
  end
  
end

module CategoriesHelper
  
  def categories_breadcrumb_path(current, linked = false, admin = false)
    if linked == true
      links = []
      current.ancestor_chain.each do |category|
        if admin == true
          links << link_to(category.name, admin_category_products_path(category))
        else
          links << link_to(category.name, category_products_path(category))
        end
      end
      links.join(" >> ").html_safe
    else
      current.ancestor_chain.collect(&:name).join(" >> ")
    end
  end
  
end

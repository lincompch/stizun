module CategoriesHelper
  
  def categories_breadcrumb(current)
    current.self_and_ancestors.collect(&:name).join(" >> ")
  end
  
end

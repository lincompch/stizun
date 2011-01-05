# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def pretty_price(price, currency = nil)
    #OPTIMIZE: In future, we will have to support multiple currencies
    begin
      currency ||= ConfigurationItem.get("currency").value
    rescue ArgumentError
      currency ||= ""
    end
    sprintf "#{currency} %.2f", price
  end
  
  def short_date(datetime)
    # Should return the date in a short form, appropriate
    # for the current locale.
    return datetime.strftime("%d.%m.%Y")
  end

  def short_address(address)
    unless address.nil?
      if address.company.blank?
        "#{address.lastname}, #{address.firstname}"
      else
        "#{address.company}. #{address.lastname}, #{address.firstname}"
      end
    end
  end
  
  # This method is based on one written by dudz.josh and available 
  # via dzone: http://snippets.dzone.com/posts/show/1919

#   def tree_recursive(tree, parent_id)
#     ret = "\n<ul>"
#     tree.each do |node|
#       if node.parent_id == parent_id
#         ret += "\n\t<li>"
#         ret += yield node
#         ret += tree_recursive(tree, node.id) { |n| yield n } unless node.children.empty?
#         ret += "\t</li>\n"
#       end
#     end
#     ret += "</ul>\n"
#   end
  
  
  # My own implementation -- I find it more readable
   def tree_recursive(tree, parent_id = nil, admin = false)
    output = ""
    output += "<ul>\n"
      tree.each do |node|
        if node.parent_id == parent_id
          if admin == true
            output += "\t<li>" + link_to(node.name, admin_category_products_path(node)) + "</li>\n"
          else
            output += "\t<li>" + link_to(node.name, category_products_path(node)) + "</li>\n"
          end
          output += tree_recursive(node.children, node.id, admin) unless node.children.empty?
        end
      end
    output += "</ul>\n"
    return output
   end

   def tree_recursive_for_accounts_table(tree, parent_id = nil)
    output = ""    
      tree.each do |node|
        if node.parent_id == parent_id  
          output += "<tr>\n"
          output += "\t<td>#{node.id}</td><td>" + ("&nbsp;&nbsp;" * node.ancestors.count) + link_to(node.name, admin_account_path(node)) + "</td><td>#{pretty_price(node.balance)}</td>\n"
          output += tree_recursive_for_accounts_table(node.children, node.id) unless node.children.empty?
        end
      end
    return output
   end
   
   

   
end

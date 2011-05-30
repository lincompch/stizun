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
   def tree_recursive(tree, parent_id = nil, admin = false, loopcount = 0)
    classname = "noindent" if loopcount == 0
    
    output = ""
    output += "<ul class=\"#{classname}\">\n"
    loopcount ||= 0
      tree.sort_by(&:name).each do |node|
        if node.parent_id == parent_id
          li_classname = "super" if node.children.count > 0
          if admin == true
            output += "\t<li class=\"#{li_classname}\">" + link_to(node.name, admin_category_products_path(node)) + "</li>\n"
          else
            if node.children.count == 0
              output += "\t<li class=\"#{li_classname}\">" + link_to(node.name, category_products_path(node)) + "</li>\n"
            else
              output += "\t<li class=\"#{li_classname}\">#{node.name}</li>\n"
            end
          end
          loopcount += 1
          output += tree_recursive(node.children, node.id, admin, loopcount) unless node.children.empty?
        end
      end
    output += "</ul>\n"
    return output
   end
   
   # RSS feed fetch helper   
   def display_rss_feed(limit = 10)
      output = "<div class='rss-entries'>"   
      FeedEntry.all(:limit => limit).each do |entry|
         output += "<h4><a href='#{entry.url}'>#{entry.title}</a></h4>"
         output += "<p>#{entry.content}</p>"
      end
      output += "</div>"
      output.html_safe
   end
   
end

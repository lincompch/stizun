# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def pretty_price(price, currency = nil)
    #OPTIMIZE: In future, we will have to support multiple currencies
    begin
      currency ||= ConfigurationItem.get("currency").value
    rescue ArgumentError
      currency ||= ""
    end
    currency = currency + " " unless currency.blank?
    sprintf "#{currency}%.2f", price
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
  
   def tree_recursive(tree, parent_id = nil, admin = false, loopcount = 0)
    if loopcount == 0
      classname = "noindent"
      idname = "id='treeview'"
    end 
    output = ""
    output += "<ul #{idname} class=\"#{classname}\">\n"
    loopcount ||= 0
      tree.sort_by(&:name).each_with_index do |node, index|
        
        if node.parent_id == parent_id
          li_classname = "first" if index == 0
          if admin == true
            output += "\t<li class=\"#{li_classname}\"><span>" + link_to(node.name, admin_category_products_path(node)) + "</span>\n"
          else
            if node.children.count == 0
              output += "\t<li class=\"#{li_classname}\"><span class=\"\">" + link_to(node.name, category_products_path(node)) + "</span>\n"
            else
              output += "\t<li class=\"#{li_classname}\"><span class=\"clickable\">#{node.name}</span>\n"
            end
          end
          loopcount += 1
          output += tree_recursive(node.children, node.id, admin, loopcount) unless node.children.empty?
          output += "</li>"
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

#encoding: utf-8
class PageController < ApplicationController

  def index
    @products = Product.visible.available.on_sale.paginate(:page => params[:page])
    @featured_products = Product.visible.available.featured.paginate(:page => params[:page])
    render_custom_page(self.action_name.to_s)
  end

  def tos
    render_custom_page(self.action_name.to_s)
  end

  # Uses the built-in default page
  def about
  end

  def contact
    if request.post?

      if ContactMailer.send_email(params[:from], :data => {:subject => params[:subject], 
                                                       :reason => params[:reason],
                                                       :body => params[:body]})
        redirect_to :controller => :page, :action => :contact_thanks
      else
        flash[:error] = "Ihre Nachricht konnte nicht übermittelt werden. Haben Sie eine gültige E-Mail-Adresse angegeben?"
      end
    else
      if @current_user
        @email = @current_user.email
      end
    end
  end

  def contact_thanks
  end
  
  def shipping
    begin
      @currency ||= ConfigurationItem.get("currency").value
    rescue ArgumentError
      @currency ||= ""
    end
    
    begin
      @minimum_item_count = ConfigurationItem.get("free_shipping_minimum_items").value.to_i
    rescue ArgumentError
    end
    
    begin
      @minimum_order_amount = BigDecimal.new(ConfigurationItem.get("free_shipping_minimum_amount").value)
    rescue ArgumentError
    end
    
    @shipping_calculator = ShippingCalculator.get_default
    @table = []
    @shipping_calculator.configuration.shipping_costs.each do |c|
      price = BigDecimal.new((c[:price] + (c[:price] / BigDecimal.new("100.0")) * @shipping_calculator.tax_class.percentage).to_s).rounded
      @table << {:weight_min => c[:weight_min], :weight_max => c[:weight_max], 
                 :price => price}
    end
    
  end

  def render_custom_page(page)
    path = Rails.root + "custom/pages/#{page}.html.erb"
    if path.exist?
      render path.to_s
    end
  end
end


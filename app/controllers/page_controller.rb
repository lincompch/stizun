class PageController < ApplicationController

  def index
    @products = Product.visible.available.on_sale.paginate(:page => params[:page])
    @featured_products = Product.visible.available.featured.paginate(:page => params[:page])
    render_custom_page(self.action_name.to_s)
  end

  def tos
    render_custom_page(self.action_name.to_s)
  end

  def about
    render_custom_page(self.action_name.to_s)
  end

  def contact
    render_custom_page(self.action_name.to_s)
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
      @table << {:weight_min => c[:weight_min], :weight_max => c[:weight_max], 
                 :price => BigDecimal.new((c[:price] + (c[:price] / BigDecimal.new("100.0")) * @shipping_calculator.tax_class.percentage).to_s).rounded}
    end
    
  end

  def render_custom_page(page)
    path = Rails.root + "custom/pages/#{page}.html.erb"
    if path.exist?
      render path.to_s
    end
  end
end


class PageController < ApplicationController

  def index
    @products = Product.on_sale.paginate(:page => params[:page])
    render_custom_page(self.action_name.to_s)
  end

  def tos
    render_custom_page(self.action_name.to_s)
  end

  def contact
    render_custom_page(self.action_name.to_s)
  end

  def render_custom_page(page)
    path = Rails.root + "custom/pages/#{page}.html.erb"
    if path.exist?
      render path.to_s
    end
  end
end


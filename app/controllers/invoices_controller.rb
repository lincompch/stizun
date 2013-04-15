class InvoicesController < ApplicationController
  
  def uuid
    @invoice = Invoice.find_by_uuid(params[:uuid])
     if @invoice.nil?
       flash[:error] = "This invoice does not exist."
       redirect_to root_path
     else
       @piwik = order_to_piwik(@invoice.order) unless @invoice.order.nil?
     end
  end
  
  def index
    
    @invoices =[]
    if params[:user_id]
      if current_user == User.find(params[:user_id])
        @invoices = Invoice.where( :user_id => params[:user_id]).order("status_constant ASC, created_at DESC")        
      end
    end
  
  end
  
  def order_to_piwik(order)
    require Rails.root + "lib/piwik"
    piwik = ""
    order.lines.each do |cl|
      categories = ""
      categories = cl.product.categories.collect(&:name) unless cl.product.categories.empty?
      piwik += piwik_ecommerce_item(cl.product.id, cl.product.name, 
                                    categories, cl.product.taxed_price.rounded,
                                    cl.quantity)
    end

    piwik += piwik_ecommerce_order(order.document_id, order.taxed_price.rounded.to_f, order.products_taxed_price.rounded.to_f, order.taxes.rounded.to_f, order.total_taxed_shipping_price.rounded.to_f)

    return piwik
  end
  
end

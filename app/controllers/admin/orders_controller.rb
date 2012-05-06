# -*- coding: utf-8 -*-
class Admin::OrdersController <  Admin::BaseController
  def index
    if params[:search_orders] and params[:search_orders].values.uniq != [""]
      keyword = params[:search_orders][:keyword] unless (params[:search_orders][:keyword].nil? or params[:search_orders][:keyword].blank?)
      total_minimum = params[:search_orders][:total_minimum] unless (params[:search_orders][:total_minimum].nil? or params[:search_orders][:total_minimum].blank?)
      total_maximum = params[:search_orders][:total_maximum] unless (params[:search_orders][:total_maximum].nil? or params[:search_orders][:total_maximum].blank?)
      #having_reminders = params[:search_orders][:having_reminders] unless (params[:search_orders][:having_reminders].nil? or params[:search_orders][:having_reminders] == "0")

      @orders = Order.all(:order => 'created_at DESC').collect{|order|

        if keyword
          text = " #{order.document_id} "
          text += "#{order.billing_address.block_summary} " if order.billing_address
          text += " #{order.shipping_address.block_summary} " if order.shipping_address
          text += order.lines.collect(&:text).join(" ")
          if text.downcase.parameterize(" ").include?(keyword) # .parameterize changes special characters to their base character, e.g. öóòô -> o
            matched_keyword = true
          else
            matched_keyword = false
          end
        end

        if total_minimum
          if order.taxed_price >= BigDecimal.new(total_minimum)
            matched_minimum = true
          else
            matched_minimum = false
          end
        end

        if total_maximum
          if order.taxed_price <= BigDecimal.new(total_maximum)
            matched_maximum = true
          else
            matched_maximum = false
          end
        end
 
        # If they are present, all must match (AND)
        if [matched_keyword, matched_minimum, matched_maximum].compact.uniq == [true]
          order
        end
      }.compact
    else 
      @orders = Order.all(:order => "created_at DESC")
    end
  end
  
  def create
    @order = Order.create(params[:order])
    if @order.save
     # redirect_to admin_order_path(@order)
      redirect_to admin_orders_path
    else
      render :action => 'new'
    end
  end
  
  def new
    @order = Order.new
  end
  
  def edit
    @order = Order.find(params[:id])
    if @order.tracking_codes.select{|tc| tc.new_record?}.count == 0
      @order.tracking_codes.build # Build empty tracking code so that nested attributes form works and presents an empty field for new codes
    end
    
  end
  
  def show
    @order = Order.find(params[:id])
  end
  
  def update
    @order = Order.find(params[:id])
    @order.update_attributes(params[:order])

    if @order.save
      flash[:notice] = "Order updated."
      redirect_to edit_admin_order_path @order
    else
      flash[:error] = "Error while saving order!"
      redirect_to edit_admin_order_path @order
    end
  end
  
  def destroy
    @order = Order.find(params[:id])
    if @order.destroy
      redirect_to admin_orders_path
    end
  end
  

end

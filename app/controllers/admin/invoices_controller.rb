# -*- coding: utf-8 -*-
class Admin::InvoicesController <  Admin::BaseController
  def index
    if params[:search_invoices] and params[:search_invoices].values.uniq != ["","0"]
      keyword = params[:search_invoices][:keyword] unless (params[:search_invoices][:keyword].nil? or params[:search_invoices][:keyword].blank?)
      total_minimum = params[:search_invoices][:total_minimum] unless (params[:search_invoices][:total_minimum].nil? or params[:search_invoices][:total_minimum].blank?)
      total_maximum = params[:search_invoices][:total_maximum] unless (params[:search_invoices][:total_maximum].nil? or params[:search_invoices][:total_maximum].blank?)
      having_reminders = params[:search_invoices][:having_reminders] unless (params[:search_invoices][:having_reminders].nil? or params[:search_invoices][:having_reminders] == "0")

      @invoices = Invoice.all(:order => 'created_at DESC').collect{|invoice|

        if keyword
          text = " #{invoice.document_id} "
          text += "#{invoice.billing_address.block_summary} " if invoice.billing_address
          text += " #{invoice.shipping_address.block_summary} " if invoice.shipping_address
          text += invoice.lines.collect(&:text).join(" ")

          if text.downcase.parameterize(" ").include?(keyword) # .parameterize changes special characters to their base character, e.g. öóòô -> o
            matched_keyword = true
          else
            matched_keyword = false
          end
        end

        if total_minimum
          if invoice.taxed_price >= BigDecimal.new(total_minimum)
            matched_minimum = true
          else
            matched_minimum = false
          end
        end

        if total_maximum
          if invoice.taxed_price <= BigDecimal.new(total_maximum)
            matched_maximum = true
          else
            matched_maximum = false
          end
        end
 
        if having_reminders
          if invoice.reminder_count > 0
            matched_reminders = true
          else
            matched_reminders = false
          end
        end

        # If they are present, all must match (AND)
        if [matched_keyword, matched_minimum, matched_maximum, matched_reminders].compact.uniq == [true]
          invoice
        end
      }.compact
    else
      @invoices = Invoice.all(:order => 'created_at DESC')
    end
  end
  
  def create_from_order
    @order = Order.find(params[:order_id])
    
    if !@order.invoiced?
      @invoice = Invoice.new_from_order(@order)
      if @invoice.save
      # redirect_to admin_invoice_path(@invoice)
        # Delivery is now done as after_create filter in Invoice
        #StoreMailer.invoice(@invoice).deliver
        flash[:notice] = "Invoice created."
        redirect_to :back
      else
        flash[:error] = "Could not create invoice."
        redirect_to :back
        #redirect_to :controller => 'admin/dashboard'
      end
    else
      flash[:error] = "This order was already invoiced."
      redirect_to :back
      #redirect_to :controller => 'admin/dashboard'
    end
  end
  
  def resend_invoice
    @invoice = Invoice.find(params[:id])
    if @invoice
      address_string = @invoice.notification_email_addresses.join(", ")
      if StoreMailer.invoice(@invoice).deliver  
        flash[:notice] = "Invoice resent to: #{address_string}"
      else
        flash[:error] = "Mail system error while delivering invoice."
      end
    else
      flash[:error] = "Invoice with ID #{params[:id]} not found."
    end
    redirect_to :back
  end

  def send_payment_reminder
    @invoice = Invoice.find(params[:id])
    if @invoice
      address_string = @invoice.notification_email_addresses.join(", ")
      if StoreMailer.payment_reminder(@invoice).deliver
        new_reminder_count = @invoice.reminder_count + 1
        @invoice.update_attributes(:reminder_count => new_reminder_count,
                                   :last_reminded_at => DateTime.now)        
        flash[:notice] = "Payment reminder sent to: #{address_string}"
      else
        flash[:error] = "Mail system error while delivering reminder."
      end
    else
      flash[:error] = "Invoice with ID #{params[:id]} not found."
    end
    redirect_to :back
  end


  
  def new
    @invoice = Invoice.new
  end
  
  def edit
    @invoice = Invoice.find(params[:id])
  end
  
  def show
    @invoice = Invoice.find(params[:id])
  end
  
  def update
    @invoice = Invoice.find(params[:id])
    @invoice.update_attributes(params[:invoice])
    
    if @invoice.save
      flash[:notice] = "Invoice updated."
      redirect_to edit_admin_invoice_path @invoice
    else
      flash[:error] = "Error while saving invoice"
      redirect_to edit_admin_invoice_path @invoice
    end
  end
  
  def destroy
    @invoice = Invoice.find(params[:id])
    if @invoice.destroy
      redirect_to admin_invoices_path
    end
  end
  

end

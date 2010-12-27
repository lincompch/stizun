class StoreMailer < ActionMailer::Base
  helper :application  
  
  default :from => APP_CONFIG['default_from_email']
  
  def order_confirmation(user, order)

    #recipients  order.notification_email_addresses
    #subject    
    #body       :user => user, :order => order
    @user = user
    @order = order
    subject = "#{APP_CONFIG['email_subject_prefix']} #{t("stizun.store_mailer.order_confirmation_subject")}"
    
    mail(:to => order.notification_email_addresses,
         :subject => subject) do |format|
      format.text #{ render :text => "This is text!" }
      #format.html #{ render :text => "<h1>This is HTML</h1>" }
    end
  end

  def invoice(invoice)

    #recipients  invoice.notification_email_addresses
    #body       :invoice => invoice
    subject = "#{APP_CONFIG['email_subject_prefix']} #{t("stizun.store_mailer.invoice_notification_subject")}"
    @invoice = invoice
    mail(:to => invoice.notification_email_addresses,
         :subject => subject) do |format|
      format.text #{ render :text => "This is text!" }
      #format.html #{ render :text => "<h1>This is HTML</h1>" }
    end
  end

    
  
end

class StoreMailer < ActionMailer::Base
  helper :application
  helper :store_mailer
  
  default :from => APP_CONFIG['default_from_email'] || 'stizun@localhost'

  
  def self.template_path(view_name)
    begin
      template_dir = "store_mailer/templates/#{ConfigurationItem.get("email_template_directory").value}"
    rescue ArgumentError
      template_dir = "store_mailer"
    end
    "#{template_dir}/#{view_name}"
  end
  
  
  def order_confirmation(user, order)

    @user = user
    @order = order
    subject = "#{APP_CONFIG['email_subject_prefix']} #{t("stizun.store_mailer.order_confirmation_subject")}"
    
    mail(:to => order.notification_email_addresses,
         :subject => subject) do |format|
      format.text { render StoreMailer.template_path("order_confirmation") }
      #format.html #{ render :text => "<h1>This is HTML</h1>" }
    end
  end

  def invoice(invoice)
    
    subject = "#{APP_CONFIG['email_subject_prefix']} #{t("stizun.store_mailer.invoice_notification_subject")}"
    @invoice = invoice
    mail(:to => invoice.notification_email_addresses,
         :subject => subject) do |format|
      
      
      format.text { render StoreMailer.template_path("invoice") }
      #format.html #{ render :text => "<h1>This is HTML</h1>" }
    end
  end

end

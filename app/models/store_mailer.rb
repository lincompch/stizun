class StoreMailer < ActionMailer::Base
  helper :application
  helper :store_mailer

  @from = APP_CONFIG['default_from_email'] || 'stizun@localhost'
  default :from => @from
  default :bcc => @from
  
  def self.template_path(view_basename)
    path = Rails.root + "custom/store_mailer/#{view_basename}.erb"
    if path.exist?
      template_dir = path
    else
      template_dir = Rails.root + "app/views/store_mailer/#{view_basename}.erb"
    end
    
    "#{template_dir.to_s}"
  end
  
  
  def order_confirmation(user, order)
    @from = APP_CONFIG['default_from_email'] || 'stizun@localhost'
    @user = user
    @order = order
    subject = "#{APP_CONFIG['email_subject_prefix']} #{t("stizun.store_mailer.order_confirmation_subject")}"
    
    mail(:to => order.notification_email_addresses,
         :bcc => @from,
         :subject => subject) do |format|
      format.text { render StoreMailer.template_path("order_confirmation") }
    end
  end

  def invoice(invoice)
    @from = APP_CONFIG['default_from_email'] || 'stizun@localhost'
    subject = "#{APP_CONFIG['email_subject_prefix']} #{t("stizun.store_mailer.invoice_notification_subject")}"
    @invoice = invoice
    mail(:to => invoice.notification_email_addresses,
         :bcc => @from,
         :subject => subject) do |format|
      
      
      format.text { render StoreMailer.template_path("invoice") }
    end
  end

end

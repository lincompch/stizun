class StoreMailer < ActionMailer::Base
  helper :application  
  
  def order_confirmation(user, order)

    recipients  order.notification_email_addresses
    from       "info@lincomp.org"
    subject    "[Lincomp] Order confirmation"
    body       :user => user, :order => order

  end

  def invoice(invoice)

    recipients  invoice.notification_email_addresses
    from       "info@lincomp.org"
    subject    "[Lincomp] Invoice for payment"
    body       :invoice => invoice

  end

    
  
end

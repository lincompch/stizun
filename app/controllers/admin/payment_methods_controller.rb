class Admin::PaymentMethodsController < Admin::BaseController
  
  def index
    @payment_methods = PaymentMethod.all
  end
end

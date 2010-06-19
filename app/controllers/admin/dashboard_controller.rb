class Admin::DashboardController <  Admin::BaseController

  def index
    @orders = Order.unprocessed.all
    @orders_to_ship = Order.to_ship.all
    @orders_to_be_paid = Order.awaiting_payment.all
    @invoices = Invoice.unpaid.all
  end 

end
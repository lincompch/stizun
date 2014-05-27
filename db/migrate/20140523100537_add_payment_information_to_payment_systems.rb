class AddPaymentInformationToPaymentSystems < ActiveRecord::Migration
  def change
    add_column :payment_methods, :requires_bank_information, :boolean, :default => true
    add_column :payment_methods, :requires_paypal_information, :boolean, :default => false
  end
end

class InsertDefaultPaymentMethods < ActiveRecord::Migration
  def self.up
     PaymentMethod.create(:name => 'Vorkasse', :allows_direct_shipping => false)
     PaymentMethod.create(:name => 'Rechnung/Bankzahlung', :allows_direct_shipping => true)
  end

  def self.down
     PaymentMethod.destroy_all
  end
end

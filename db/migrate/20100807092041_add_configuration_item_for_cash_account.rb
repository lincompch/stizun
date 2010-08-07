class AddConfigurationItemForCashAccount < ActiveRecord::Migration
  def self.up
    ca = Account.find_by_name("Bank")
    unless ca
      ca = Account.create(:name => 'Bank')
      ca.parent = Account.find_by_name("Assets")
      ca.save
    end
    
    ci = ConfigurationItem.new(:key => 'cash_account_id', :value => ca.id, :name => "Cash Account ID", :description => "The cash account that invoice payments are booked to by default, e.g. Bank/Invoices.")
    ci.save
      
  end

  def self.down
    ci = ConfigurationItem.get('cash_account_id')
    ci.destroy
  end
end

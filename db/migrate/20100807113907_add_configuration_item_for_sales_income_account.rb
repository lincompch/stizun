class AddConfigurationItemForSalesIncomeAccount < ActiveRecord::Migration
  def self.up
    
    sia = Account.find_by_name("Sales Income")
    unless sia
      sia = Account.create(:name => 'Sales Income')
      sia.parent = Account.find_by_name("Income")
      sia.save
    end
    
    ci = ConfigurationItem.new(:key => 'sales_income_account_id', :value => sia.id, :name => "Sales Income Account ID", :description => "The income account where sold items are booked to by default.")
    ci.save
      
  end

  def self.down
    ci = ConfigurationItem.get('sales_income_account_id')
    ci.destroy
  end
end
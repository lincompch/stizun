class AddConfigurationitemsForAccountingSystem < ActiveRecord::Migration
  def self.up
    receivable = Account.find_by_name('Accounts Receivable')
    ConfigurationItem.create(:name => 'Accounts Receivable ID',
                             :key => 'accounts_receivable_id',
                             :value => receivable.id,
                             :description => "The ID of the account under which additional accounts receivable are created when the system needs to automatically create them. This is extremely important, e.g. during the order process.")

  end

  def self.down
  end
end

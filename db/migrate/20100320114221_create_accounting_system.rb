class CreateAccountingSystem < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :parent_id # for acts_as_tree
      t.integer :user_id
      t.string  :name
      t.integer :type_constant # Assets? Liabilities? etc.
      t.timestamps
    end

    # Text-only historical representation of accounting transactions
    create_table :journal_entries do |t|
      t.string :text
      t.string :credit_account_name
      t.string :debit_account_name
      t.timestamps
    end
    
    # The proper transactions go here
    create_table :account_transactions do |t|
      t.string  :note
      t.integer :credit_account_id
      t.string  :credit_account_type
      t.integer :debit_account_id
      t.string  :debit_account_type
      t.decimal :amount
      t.integer :target_object_id
      t.string  :target_object_type
      t.timestamps
    end
    
    assets = Account.create(:name => 'Assets', :type_constant => Account::ASSETS)
    liabilities = Account.create(:name => 'Liabilities', :type_constant => Account::LIABILITIES)
    income = Account.create(:name => 'Income', :type_constant => Account::INCOME)
    expense = Account.create(:name => 'Expense', :type_constant => Account::EXPENSE)
    receivable = Account.create(:name => 'Accounts Receivable')
    ConfigurationItem.create(:name => 'Accounts Receivable ID', 
                             :key => 'accounts_receivable_id', 
                             :value => receivable.id,
                             :description => "The ID of the account under which additional accounts receivable are created when the system needs to automatically create them. This is extremely important, e.g. during the order process.")
    assets.children << receivable
    assets.save
    
    
  end

  def self.down
    drop_table :accounts
    drop_table :journal_entries
    drop_table :account_transactions
  end
end

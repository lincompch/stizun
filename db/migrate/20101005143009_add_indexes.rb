class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :account_transactions, [:credit_account_id, :debit_account_id]

    add_index :account_transactions, [:debit_account_id, :credit_account_id]

    add_index :account_transactions, :debit_account_id
    add_index :account_transactions, :credit_account_id

    add_index :accounts, :user_id
    add_index :accounts, :parent_id

    add_index :addresses, :user_id
    add_index :carts, :user_id
    add_index :categories, :parent_id


    add_index :categories_products, [:product_id, :category_id]
    add_index :categories_products, [:category_id, :product_id]
    #add_index :categories_products, :product_id
    #add_index :categories_products, :category_id


    add_index :configuration_items, :key
    add_index :document_lines, :product_id
    add_index :document_lines, :cart_id
    add_index :document_lines, :invoice_id
    add_index :document_lines, :order_id

    add_index :invoice_lines, :invoice_id

    add_index :invoices, :user_id
    add_index :invoices, :uuid
    add_index :invoices, :order_id

    add_index :orders, :user_id
    add_index :payment_methods_users, [:user_id, :payment_method_id]
    add_index :payment_methods_users, [:payment_method_id, :user_id]
    add_index :payment_methods_users, :payment_method_id
    add_index :payment_methods_users, :user_id


    add_index :products, :supply_item_id
    add_index :products, :supplier_id

    add_index :shipping_costs, :shipping_rate_id
    add_index :suppliers, :shipping_rate_id

    add_index :supply_items, :supplier_id

  end

  def self.down
  end
end

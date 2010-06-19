class AllowDefaultPaymentMethod < ActiveRecord::Migration
  def self.up
    add_column :payment_methods, :default, :boolean
  end

  def self.down
    remove_column :payment_methods, :default
  end
end

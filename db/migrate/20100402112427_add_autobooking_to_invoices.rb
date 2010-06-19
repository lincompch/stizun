class AddAutobookingToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :autobook, :boolean, :default => true
  end

  def self.down
    remove_column :invoices, :autobook
  end
end

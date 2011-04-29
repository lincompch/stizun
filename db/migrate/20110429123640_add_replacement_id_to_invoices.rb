class AddReplacementIdToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :replacement_id, :integer
  end

  def self.down
    remove_column :invoices, :replacement_id
  end
end

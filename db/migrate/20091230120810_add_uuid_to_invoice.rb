class AddUuidToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :uuid, :string
  end

  def self.down
    remove_column :invoices, :uuid
  end
end

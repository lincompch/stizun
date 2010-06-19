class AddDocumentNumber < ActiveRecord::Migration
  def self.up
    add_column :invoices, :document_number, :integer
    add_column :orders, :document_number, :integer
    
  end

  def self.down
    remove_column :invoices, :document_number
    remove_column :orders, :document_number
    
  end
end

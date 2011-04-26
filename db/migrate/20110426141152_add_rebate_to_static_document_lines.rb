class AddRebateToStaticDocumentLines < ActiveRecord::Migration
  def self.up
    add_column :static_document_lines, :single_rebate, :decimal, :precision => 63, :scale => 30, :default => 0.0
  end

  def self.down
    remove_column :static_document_lines, :single_rebate
  end
end

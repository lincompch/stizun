class RemoveTaxFromDocumentLines < ActiveRecord::Migration
  def self.up
    remove_column :document_lines, :tax
  end

  def self.down
    add_column :document_lines, :tax, :decimal, :precision => 63, :scale => 30
  end
end

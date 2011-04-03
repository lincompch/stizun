class AddManufacturerInfoToStaticDocumentLines < ActiveRecord::Migration
  def self.up
    add_column :static_document_lines, :manufacturer, :string
    add_column :static_document_lines, :manufacturer_product_code, :string
    add_column :static_document_lines, :product_id, :integer
  end

  def self.down
    remove_column :static_document_lines, :manufacturer
    remove_column :static_document_lines, :manufacturer_product_code
    remove_column :static_document_lines, :product_id
  end
end

class DropUnusedColumns < ActiveRecord::Migration
  def up
    remove_column :document_lines, :price
    remove_column :static_document_lines, :single_rounded_price
  end

  def down
  end
end

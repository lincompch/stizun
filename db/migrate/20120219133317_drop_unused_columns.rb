class DropUnusedColumns < ActiveRecord::Migration
  def up
    drop_column :document_lines, :price
    drop_column :static_document_lines, :single_rounded_price
  end

  def down
  end
end

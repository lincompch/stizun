class OldOrderMigration < ActiveRecord::Migration
  def self.up
    rename_column :document_lines, :order_id, :old_order_id
  end

  def self.down
    rename_column :document_lines, :old_order_id, :order_id
  end
end

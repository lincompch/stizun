class AddWorkflowStatusToSupplyItems < ActiveRecord::Migration
  def self.up
    add_column :supply_items, :notes, :string
    add_column :supply_items, :workflow_status, :integer, :default => 1
  end

  def self.down
    remove_column :supply_items, :notes
    remove_column :supply_items, :workflow_status
  end
end

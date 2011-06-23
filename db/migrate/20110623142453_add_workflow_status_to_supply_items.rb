class AddWorkflowStatusToSupplyItems < ActiveRecord::Migration
  def self.up
    add_column :supply_items, :workflow_status_constant, :integer, :default => 1
  end

  def self.down
    remove_column :supply_items, :workflow_status_constant
  end
end

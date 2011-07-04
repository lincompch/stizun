class AddWorkflowNotesToSupplyItems < ActiveRecord::Migration
  def self.up
    add_column :supply_items, :notes, :string
  end

  def self.down
    remove_column :supply_items, :notes
  end
end

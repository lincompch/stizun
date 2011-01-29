class AddStatusConstToSupplyItems < ActiveRecord::Migration
  def self.up
    add_column :supply_items, :status_constant, :integer
    SupplyItem.all.each do |si|
      si.update_attributes(:status_constant => SupplyItem::AVAILABLE)
    end
  end

  def self.down
    remove_column :supply_items, :status_constant
  end
end

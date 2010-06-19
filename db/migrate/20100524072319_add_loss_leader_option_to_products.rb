class AddLossLeaderOptionToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :is_loss_leader, :boolean
  end

  def self.down
    remove_column :products, :is_loss_leader
  end
end

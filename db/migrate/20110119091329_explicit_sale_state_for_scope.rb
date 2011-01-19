class ExplicitSaleStateForScope < ActiveRecord::Migration
  def self.up
    add_column :products, :sale_state, :boolean, :default => false
  end

  def self.down
    remove_column :products, :sale_state
  end
end

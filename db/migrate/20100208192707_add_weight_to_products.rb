class AddWeightToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :weight, :float
  end

  def self.down
  end
end

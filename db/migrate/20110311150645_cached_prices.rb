class CachedPrices < ActiveRecord::Migration
  def self.up

    add_column :products, :cached_price, :decimal, :precision => 63, :scale => 30
    add_column :products, :cached_taxed_price, :decimal, :precision => 63, :scale => 30
  end

  def self.down
  end
end

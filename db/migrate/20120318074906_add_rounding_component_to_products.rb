class AddRoundingComponentToProducts < ActiveRecord::Migration
  def change
    add_column :products, :rounding_component, :decimal,  :precision => 63, :scale => 30

  end
end

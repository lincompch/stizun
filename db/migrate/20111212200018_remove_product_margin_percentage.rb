class RemoveProductMarginPercentage < ActiveRecord::Migration
  def change
    remove_column :products, :margin_percentage
  end

end

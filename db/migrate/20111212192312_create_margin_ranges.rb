class CreateMarginRanges < ActiveRecord::Migration
  def change
    create_table :margin_ranges do |t|
      t.float :start_price
      t.float :end_price
      t.float :margin_percentage
    end
    
  end
end

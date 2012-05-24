class AddTimestampsToMarginRanges < ActiveRecord::Migration
  def change
    add_column :margin_ranges, :updated_at, :datetime
    add_column :margin_ranges, :created_at, :datetime
    add_column :margin_ranges, :recalculated_at, :datetime
  end
end

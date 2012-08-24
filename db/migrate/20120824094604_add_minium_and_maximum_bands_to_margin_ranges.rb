class AddMiniumAndMaximumBandsToMarginRanges < ActiveRecord::Migration
  def change
    add_column :margin_ranges, :band_minimum, :float
    add_column :margin_ranges, :band_maximum, :float
  end
end

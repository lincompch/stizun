class CreateNumerators < ActiveRecord::Migration
  def self.up
    create_table :numerators do |t|
      t.integer :count
      t.timestamps
    end
    Numerator.create(:count => 0)
  end

  def self.down
    drop_table :numerators
  end
end

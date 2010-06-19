class CreateTaxClasses < ActiveRecord::Migration
  def self.up
    create_table :tax_classes do |t|
      t.string :name
      t.decimal :percentage, :precision => 8, :scale => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :tax_classes
  end
end

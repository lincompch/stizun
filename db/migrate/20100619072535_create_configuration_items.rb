class CreateConfigurationItems < ActiveRecord::Migration
  def self.up
    create_table :configuration_items do |t|

      t.timestamps
      t.string :key
      t.string :value
      t.string :name
      t.string :description
    end
  end

  def self.down
    drop_table :configuration_items
  end
end

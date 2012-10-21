class AddEanCodeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :ean_code, :string
  end
end

class AddIndexesOnSupplierProductCode < ActiveRecord::Migration
  def up
    add_index(:products, :supplier_product_code)
    #add_index(:products, :supplier_id)
    add_index(:products, :tax_class_id)
    add_index(:products, :is_featured)
    add_index(:products, :is_available)
    add_index(:products, :sale_state)


    #add_index(:products, :supply_item_id)


    add_index(:product_sets, :component_id)
    add_index(:product_sets, :product_id)


    add_index(:supply_items, :supplier_product_code)
    #add_index(:supply_items, :supplier_id)
    add_index(:supply_items, :status_constant)

  end

  def down

  end
end

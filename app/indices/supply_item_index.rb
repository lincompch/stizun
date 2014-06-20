ThinkingSphinx::Index.define :supply_item, :with => :active_record, :delta => true do

  indexes(:name, :sortable => true)
  indexes(:category_string, :sortable => true)
  indexes(:manufacturer, :sortable => true)
  indexes(:supplier_product_code, :sortable => true)
  indexes(:manufacturer_product_code, :sortable => true)

  indexes description
  indexes status_constant

  # attributes
  has created_at, updated_at
  has supplier_id
  # has category(:ancestry), :as => :category_ids, :type => :multi
end

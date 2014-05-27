ThinkingSphinx::Index.define :product, :with => :active_record do

  indexes(:name, :sortable => true)
  indexes purchase_price, :sortable => true
  indexes supplier_id, manufacturer, short_description, description, supplier_product_code, manufacturer_product_code

  has(:cached_taxed_price, :sortable => true)
  has categories(:id), :as => :category_id

  # attributes
  has(:id, created_at, updated_at, is_available, is_featured, is_visible)

  set_property :delta => true
end


# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100619072535) do

  create_table "account_transactions", :force => true do |t|
    t.string   "note"
    t.integer  "credit_account_id"
    t.string   "credit_account_type"
    t.integer  "debit_account_id"
    t.string   "debit_account_type"
    t.decimal  "amount"
    t.integer  "target_object_id"
    t.string   "target_object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounts", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "name"
    t.integer  "type_constant"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", :force => true do |t|
    t.string   "company"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "street"
    t.string   "postalcode"
    t.string   "city"
    t.string   "email"
    t.integer  "country_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     :default => "active"
  end

  create_table "admin_addresses", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_orders", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_products", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  add_index "categories_products", ["category_id"], :name => "index_categories_products_on_category_id"
  add_index "categories_products", ["product_id"], :name => "index_categories_products_on_product_id"

  create_table "configuration_items", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key"
    t.string   "value"
    t.string   "name"
    t.string   "description"
  end

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.string   "sortorder"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_lines", :force => true do |t|
    t.integer  "quantity"
    t.decimal  "price"
    t.decimal  "tax"
    t.integer  "product_id"
    t.string   "note"
    t.string   "type"
    t.integer  "cart_id"
    t.integer  "invoice_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories", :force => true do |t|
    t.string   "text"
    t.string   "object_type"
    t.integer  "object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_lines", :force => true do |t|
    t.integer  "quantity"
    t.string   "text"
    t.decimal  "rounded_price"
    t.decimal  "single_rounded_price"
    t.decimal  "taxes"
    t.decimal  "tax_percentage",       :precision => 8, :scale => 2
    t.integer  "invoice_id"
    t.float    "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", :force => true do |t|
    t.integer  "shipping_address_id"
    t.string   "shipping_address_type"
    t.integer  "billing_address_id"
    t.string   "billing_address_type"
    t.integer  "user_id"
    t.integer  "status_constant",       :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
    t.decimal  "shipping_cost"
    t.integer  "order_id"
    t.integer  "payment_method_id"
    t.integer  "document_number"
    t.boolean  "autobook",              :default => true
  end

  create_table "journal_entries", :force => true do |t|
    t.string   "text"
    t.string   "credit_account_name"
    t.string   "debit_account_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount"
  end

  create_table "numerators", :force => true do |t|
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_address_id"
    t.integer  "billing_address_id"
    t.string   "shipping_address_type"
    t.string   "billing_address_type"
    t.integer  "status_constant",       :default => 1
    t.integer  "payment_method_id"
    t.integer  "document_number"
  end

  create_table "pages", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_methods", :force => true do |t|
    t.string   "name"
    t.boolean  "allows_direct_shipping"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default"
  end

  create_table "payment_methods_users", :id => false, :force => true do |t|
    t.integer "payment_method_id"
    t.integer "user_id"
  end

  create_table "product_sets", :force => true do |t|
    t.integer "quantity"
    t.integer "product_id"
    t.integer "component_id"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "tax_class_id"
    t.decimal  "purchase_price",            :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "margin_percentage",         :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "sales_price",               :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.float    "weight"
    t.boolean  "direct_shipping",                                         :default => true
    t.string   "supplier_product_code"
    t.integer  "stock",                                                   :default => 0
    t.boolean  "is_available",                                            :default => true
    t.integer  "supply_item_id"
    t.string   "manufacturer_product_code"
    t.decimal  "absolute_rebate",                                         :default => 0.0
    t.decimal  "percentage_rebate",                                       :default => 0.0
    t.datetime "rebate_until"
    t.boolean  "is_loss_leader"
  end

  create_table "shipping_costs", :force => true do |t|
    t.integer  "shipping_rate_id"
    t.integer  "weight_min"
    t.integer  "weight_max"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tax_class_id"
  end

  create_table "shipping_rates", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suppliers", :force => true do |t|
    t.string   "name"
    t.integer  "address_id"
    t.integer  "shipping_rate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supply_items", :force => true do |t|
    t.string   "supplier_product_code"
    t.string   "name"
    t.float    "weight"
    t.integer  "supplier_id"
    t.string   "description"
    t.decimal  "purchase_price",            :precision => 8, :scale => 2, :default => 0.0
    t.integer  "stock"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "manufacturer_product_code"
  end

  create_table "tax_classes", :force => true do |t|
    t.string   "name"
    t.decimal  "percentage", :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token"
    t.string   "email"
    t.integer  "login_count",        :default => 0, :null => false
    t.integer  "failed_login_count", :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
  end

end

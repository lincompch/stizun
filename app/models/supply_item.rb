class SupplyItem < ActiveRecord::Base
  
  belongs_to :tax_class
  belongs_to :supplier
  has_one :product
  
  before_create :set_status_to_available_if_nil
  before_save :handle_supply_item_deletion
  
  def self.per_page
    return 100
  end
  
  # === Constants and associated methods
    
  AVAILABLE = 1
  DELETED = 2
  
  STATUS_HASH = { AVAILABLE => 'stizun.constants.available',
                  DELETED   => 'stizun.constants.deleted'}

  def self.status_to_human(status)
    # Gotta call I18n.t like this because it doesn't have the correct
    # locale set outside this definition on _some_ installations, not all.
    # Possibly broken in Rails.    
    if status.blank?
      return "not set"
    else
      return I18n.t(STATUS_HASH[status])
    end
  end
  
  def self.status_hash_for_select
    hash = []
    STATUS_HASH.each do |key,value|
      hash << [I18n.t(value), key]
    end 
    return hash

  end
  
  def status_human
    return SupplyItem::status_to_human(self.status_constant)
  end
  
  # === Named scopes

  scope :available, :conditions => { :status_constant => SupplyItem::AVAILABLE }
  scope :deleted, :conditions => { :status_constant => SupplyItem::DELETED }
  scope :unavailable, :conditions => [ "status_constant <> #{SupplyItem::AVAILABLE}"]
  
  # Thinking Sphinx configuration
  # Must come AFTER associations
  define_index do
    # fields
    indexes name, :sortable => true
    indexes manufacturer, description, supplier_product_code, manufacturer_product_code
    
    # attributes
    has created_at, updated_at
    has supplier_id
    #has suppliers(:id), :as => :supplier_id
    #has suppliers(:id), :as => :supplier_ids
    
    set_property :delta => true

  end
  
  def to_s
    "#{supplier_product_code} #{name}" 
  end
  
  # This should really be done as a default on the database instead
  def set_status_to_available_if_nil
    self.status_constant = SupplyItem::AVAILABLE if self.status_constant == nil
  end
  
  def component_of
    product_sets = ProductSet.find_all_by_component_id(self.id)
    product_sets.collect(&:product).uniq.compact
  end
  
  def retrieve_product_picture
    unless self.product.blank? or self.image_url.blank?
      require 'lib/image_handler'
      image_path = ImageHandler.get_image_by_http(self.image_url, self.id)
      unless image_path.blank?
        prod = self.product
        
        pp = ProductPicture.new
        pp.file = File.open(image_path, "r")
        prod.product_pictures << pp
        if prod.save
          logger.info "Product picture attached to #{prod.to_s}"
          return true
        else
          logger.error "Couldn't attach product picture to #{prod.to_s}"
          return false
        end
      end
    end
  end
  
  
  def handle_supply_item_deletion
    if self.status_constant_was == SupplyItem::AVAILABLE and \
       self.status_constant == SupplyItem::DELETED
      # If this supply item was used as a product component, remove it from the
      # product, disable the product.
      affected_products = self.component_of
      affected_products.each do |ap|
        ap.disable_product
      end
      
      # Disable the product because its supply item has become deleted.
      # This is different from the above, above we handle situations involving
      # _components_ and componentized products
      unless self.product.blank?
        self.product.disable_product
      end
    end
  end
   
end

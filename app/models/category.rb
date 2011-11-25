class Category < ActiveRecord::Base
  has_and_belongs_to_many :products
  belongs_to :supplier
  has_many :supply_items

  #acts_as_tree :order => "name"

  acts_as_nested_set :order => "name"

  after_save :expire_cache_fragments
  after_save :generate_ancestry
  after_destroy :expire_cache_fragments

  def fully_qualified_name
    trail = ""
    for cat in ancestors
      trail += cat.name
      trail += " >> "
    end
    trail += name
    return trail
  end

  # Abstraction so we can switch out better_nested_set for something
  # else if it becomes necessary. Returns the category and all its
  # ancestors up to the root of the tree or graph.
  def ancestor_chain
    self_and_ancestors
  end

  # Returns all child, subchild, ... , categories with self
  def children_categories
    #self_and_descendants.collect(&:children_categories)
    ([self] + children.collect(&:children_categories)).flatten
  end

  # Returns all child, subchild supply items
  def children_supply_items
    ([self.supply_items] + children.collect(&:children_supply_items)).flatten
  end


  # It will only look for categories in one supplier's node
  def create_if_not_present(name, level = nil, supplier = nil, create = true)
    categories = children_categories.flatten
    tab = []
    categories.each { |category| tab << category if category.name == name }
    found = tab.index {|category| category.level.eql? level }
    if found
      tab[found]
    elsif create
      Category.create!(:name => name, :parent_id => self.id, :supplier => supplier) unless name.empty?
    end
  end

  # Finding correct category for a supplyitem
  def category_from_csv(category1, category2, category3)
    if !(category3.blank?)
      self.create_if_not_present(category3, 3, nil, false).id
    elsif !(category2.blank?)
      self.create_if_not_present(category2, 2, nil, false).id
    elsif !(category1.blank?)
      self.create_if_not_present(category1, 1, nil, false).id
    else
      self.reload
      self.create_if_not_present("Without category", 1, self.supplier, true).id
    end
  end

  # Whenever any category changes, we need to expire all category-related
  # caches
  def expire_cache_fragments
    Supplier.all.each do |sup|
      Rails.cache.delete("supplier_#{sup.id}_categories_sorted")
      Rails.cache.delete("#{sup.id}_select_tag")
    end
  end

  def generate_ancestry
    # callbacks have to be turned off - to avoid loop execution
    #puts self.ancestor_chain.map(&:id).join("/")
    Category.skip_callback("save", :after, :generate_ancestry)
    update_attributes(:ancestry => self.ancestor_chain.map(&:id).join("/"))
    Category.set_callback("save", :after, :generate_ancestry)

  end
end


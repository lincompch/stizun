class Category < ActiveRecord::Base
  has_and_belongs_to_many :products
  has_many :supply_items

  #acts_as_tree :order => "name"

  acts_as_nested_set :order => "name"

  after_save :expire_cache_fragments
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

  # Whenever any category changes, we need to expire all category-related
  # caches
  def expire_cache_fragments
    Supplier.all.each do |sup|
      Rails.cache.delete("supplier_#{sup.id}_categories_sorted")
      Rails.cache.delete("#{sup.id}_select_tag")
    end
  end

end

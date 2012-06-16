
# This class helps us schedule delayed jobs by setting everying up for a specific job, e.g.
# requiring external libraries, instantiating objects, running methods on them...
class JobExecutor


  def self.require_utility_class(supplier)
    class_path = Rails.root + "lib/#{supplier.utility_class_name.underscore}"
    require class_path
  end

  def self.import_supply_items(supplier_name, filename)
    supplier = Supplier.where(:name => supplier_name).first
    if supplier
      require_utility_class(supplier)
      util = supplier.utility_class_name.constantize.new
      util.import_supply_items(filename)
    else
      raise "Supplier #{supplier_name} does not exist. Aborting import."
    end
  end

  def self.update_supply_items(supplier_name, filename)
    supplier = Supplier.where(:name => supplier_name).first
    if supplier
      require_utility_class(supplier)
      util = supplier.utility_class_name.constantize.new
      util.update_supply_items(filename)      
    else
      raise "Supplier #{supplier_name} does not exist. Aborting update."
    end
  end

  def self.export_product_csv(path)
    Product.export_available_to_csv(path)
  end

  def self.update_price_and_stock
    Product.update_price_and_stock
  end



end
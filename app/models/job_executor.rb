class JobExecutor

  def self.require_utility_class(supplier)
    class_path = Rails.root + "lib/#{supplier.utility_class_name.underscore}"
    require class_path
  end

  def self.import_supply_items(supplier_name, filename)
    supplier = Supplier.where(:name => supplier_name).first
    if supplier
      self.get_price_files(supplier_name)
      require_utility_class(supplier)
      util = supplier.utility_class_name.constantize.new
      util.import_supply_items(filename)
    else
      raise "Supplier '#{supplier_name}' does not exist. Aborting import."
    end
  end

  def self.update_supply_items(supplier_name, filename)
    supplier = Supplier.where(:name => supplier_name).first
    if supplier
      self.get_price_files(supplier_name)
      require_utility_class(supplier)
      util = supplier.utility_class_name.constantize.new
      util.update_supply_items(filename)      
    else
      raise "Supplier '#{supplier_name}' does not exist. Aborting update."
    end
  end

  def self.export_product_csv(path)
    Product.export_available_to_csv(path)
  end

  def self.get_price_files(supplier_name)
    csv_retrieval_script_path = "/home/lincomp/get_price_files.sh"
    if File.exists?(csv_retrieval_script_path)
      system("#{csv_retrieval_script_path} '#{supplier_name}'")
      if $?.exitstatus == 0
        return true
      else
        return false
      end
    else
      raise "No CSV file retrieval script present at #{csv_retrieval_script_path}. Aborting import."
    end
  end

end

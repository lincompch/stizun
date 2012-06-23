
# This class helps us schedule delayed jobs by setting everying up for a specific job, e.g.
# requiring external libraries, instantiating objects, running methods on them...
class JobExecutor

  # Go through all the job configurations, see if any of the repetition configurations affect today.
  # If they affect today, schedule the job at the right time today via Delayed::Job's run_at option.
  # If they don't affect today, ignore them.
  def self.schedule_jobs
    todays_configurations = JobConfiguration.affecting_day(Date.today)
    todays_configurations.each do |jc|
      # TODO: determine whether we have to schedule the job today, schedule it
    end

  end


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
      raise "Supplier '#{supplier_name}' does not exist. Aborting import."
    end
  end

  def self.update_supply_items(supplier_name, filename)
    supplier = Supplier.where(:name => supplier_name).first
    if supplier
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

  def self.update_price_and_stock
    Product.update_price_and_stock
  end



end
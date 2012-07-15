
# This class helps us schedule delayed jobs by setting everying up for a specific job, e.g.
# requiring external libraries, instantiating objects, running methods on them...
class JobExecutor

  # Go through all the job configurations, see if any of the repetition configurations affect today.
  # If they affect today, schedule the job at the right time today via Delayed::Job's run_at option.
  # If they don't affect today, ignore them.
  def self.schedule_jobs
    todays_configurations = JobConfiguration.affecting_day(Date.today)
    todays_configurations.each do |jc|
      self.handle_job_submission(jc)
    end
  end

  def self.handle_job_submission(job_configuration)
    # Since this was called from a list of jobs affecting today, we know the correct run_at time must be sometime today
    # We set run_at to this, as our basic date and time, then configure more the minute and hour later
    if job_configuration.job_repetition
      run_at = DateTime.parse("#{job_configuration.job_repetition.hour}:#{job_configuration.job_repetition.minute}+0200")
    elsif job_configuration.run_at
      run_at = job_configuration.run_at
    end

    # Don't submit jobs for run_at times that are in the past anyhow
    if run_at > DateTime.now
      matches = []
      jobs = Delayed::Job.where(:run_at => run_at)
      jobs.each do |job|
        if job_configuration.equal_to_job?(job) == true
          matches << true
        end
      end
      job_configuration.submit_delayed_job(run_at) if (matches.uniq == [false] or matches == [])
    end
  end

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
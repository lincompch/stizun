class JobConfiguration < ActiveRecord::Base

  belongs_to :job_repetition
  belongs_to :job_configuration_template


  def self.affecting_day(date)
    results = []

    affected_repetitions = JobRepetition.where("month = ? or month IS NULL", date.month)\
                                        .where("dom = ? or dom IS NULL", date.day)\
                                        .where("dow = ? or dow IS NULL", date.strftime("%w").to_i)

    affected_repetitions.each do |repetition|
      results += repetition.job_configurations
    end               
    affected_through_run_at = self.where(:run_at => date.beginning_of_day..date.end_of_day)
    results += affected_through_run_at

    return results
  end

  def configuration_complete?
    completeness = false
    if self.job_configuration_template
      completeness = ( !self.job_configuration_template.job_class.blank? & !self.job_configuration_template.job_method.blank? )
    end
    return completeness
  end

  def submit_delayed_job
    if configuration_complete?
      klass = job_configuration_template.job_class.constantize
      argument_string = job_configuration_template.job_arguments
      unless argument_string.blank?
        arguments_array = argument_string.split(",")
      end
      # Use delayed_job to create a job of the form: Klass.delay.method(arguemnts)
      klass.delay.send(job_configuration_template.job_method, *arguments_array)
    else
      raise "Can't submit job, its configuration is incomplete."
    end
  end


end
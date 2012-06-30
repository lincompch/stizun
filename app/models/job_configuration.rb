require Rails.root + 'lib/alltron_util'
require Rails.root + 'lib/ingram_util'
require Rails.root + 'lib/jet_util'

class JobConfiguration < ActiveRecord::Base

  belongs_to :job_repetition
  belongs_to :job_configuration_template

  validates_presence_of :job_configuration_template

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

  def submit_delayed_job(run_at = nil)
    if configuration_complete?
      klass = job_configuration_template.job_class.constantize
      argument_string = job_configuration_template.job_arguments
      unless argument_string.blank?
        arguments_array = argument_string.split(",")
      end


      # TODO: get the job ID after submission and attach it to the job configuration table to reflect its state etc.

      if run_at
        # Use delayed_job to create a job of the form: Klass.delay.method(arguments)
        klass.delay(:run_at => run_at).send(job_configuration_template.job_method, *arguments_array)        
      else
        # Use delayed_job to create a job of the form: Klass.delay.method(arguments)
        klass.delay.send(job_configuration_template.job_method, *arguments_array)
      end
    else
      raise "Can't submit job, its configuration is incomplete."
    end
  end

  def equal_to_job?(job)
    job_object = YAML::load(job.handler)
    if (job_object.args[0].to_s == job_configuration_template.job_method and\
        job_object.args[1].to_s ==  job_configuration_template.job_arguments and\
        job_object.object.to_s == job_configuration_template.job_class)
      return true
    else
      return false
    end
  end

end
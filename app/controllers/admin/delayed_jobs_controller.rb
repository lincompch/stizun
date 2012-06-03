class Admin::DelayedJobsController <  Admin::BaseController

  def index
    @jobs = DelayedJob.all
  end 


  def new
  	@available_jobs = JSON.load(File.open(Rails.root + "config/job_configuration.sample.json"))
  	
  end

  def compact_job_name

  end

end

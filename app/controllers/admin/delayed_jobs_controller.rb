class Admin::DelayedJobsController <  Admin::BaseController

  def index
    @jobs = Delayed::Job.all
  end 


  def new
    @available_job_configurations = JobConfigurationTemplate.order(:job_class, :job_method)   
  end

  def create
    job_configuration = JobConfiguration.new(:job_configuration_template_id => params[:job_configuration_template_id],
                                             :job_repetition_id => params[:job_repetition_id])
    if job_configuration.save
      flash[:notice] = "Configuration saved"
      redirect_to :action => :new
    else
      flash[:error] = "Can't save configuration"
      redirect_to :action => :new
    end

  end

end

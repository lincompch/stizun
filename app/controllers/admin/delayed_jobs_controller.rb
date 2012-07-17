class Admin::DelayedJobsController <  Admin::BaseController

  def index
    @jobs = Delayed::Job.all
    @job_configurations = JobConfiguration.all

  end 


  def new
    @jobs = Delayed::Job.all
    @job_configuration_templates = JobConfigurationTemplate.order(:job_class, :job_method)
    @job_configurations = JobConfiguration.all
  end

  def create
    if params[:run_at].has_key?(:year) and !params[:run_at][:year].blank?
      run_at = Time.zone.parse("#{params[:run_at][:day].to_i}.#{params[:run_at][:month].to_i}.#{params[:run_at][:year].to_i} #{params[:run_at][:hour].to_i}:#{params[:run_at][:minute].to_i}")
    end
    job_configuration = JobConfiguration.new(:job_configuration_template_id => params[:job_configuration_template_id],
                                             :job_repetition_id => params[:job_repetition_id],
                                             :run_at => run_at)
    if job_configuration.save
      flash[:notice] = "Configuration saved"
      redirect_to :action => :new
    else
      flash[:error] = "Can't save configuration"
      redirect_to :action => :new
    end

  end

end

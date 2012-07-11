class Admin::JobConfigurationsController <  Admin::BaseController


  def destroy
    job_configuration = JobConfiguration.find(params[:id])
    if job_configuration.destroy
      flash[:notice] = "Job configuration destroyed"
    else
      flash[:error] = "Job configuration could not be destroyed"
    end
    redirect_to new_admin_delayed_job_path
  end


end
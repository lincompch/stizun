class Admin::ConfigurationItemsController < Admin::BaseController
  
  def index
    @configuration_items = ConfigurationItem.all
  end
  
  def edit
    @ci = ConfigurationItem.find(params[:id])
  end
  
  def new
    @ci = ConfigurationItem.new
  end
  
  def create
    if @ci = ConfigurationItem.create(params[:configuration_item])
      flash[:notice] = "Configuration item saved"
      redirect_to admin_configuration_items_path
    else
      flash[:error] = "Configuration item could not be saved"
      redirect_to edit_admin_configuration_item_path(@ci)
    end
  end
  
  def update
    @ci = ConfigurationItem.find(params[:id])
    @ci.update_attributes(params[:configuration_item])
    if @ci.save
      flash[:notice] = "Item updated"
    else
      flash[:error] = "Error updating item"
    end
      redirect_to edit_admin_configuration_item_path(@ci)
  end
  
end

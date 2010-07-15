class Admin::ConfigurationItemsController < Admin::BaseController
  
  def index
    @configuration_items = ConfigurationItem.all
  end
  
  def edit
    @ci = ConfigurationItem.find(params[:id])
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

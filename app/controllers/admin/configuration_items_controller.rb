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
    if @ci = ConfigurationItem.create(configuration_item_attributes)
      flash[:notice] = "Configuration item saved"
      redirect_to admin_configuration_items_path
    else
      flash[:error] = "Configuration item could not be saved"
      redirect_to edit_admin_configuration_item_path(@ci)
    end
  end
  
  def update
    @ci = ConfigurationItem.find(params[:id])
    @ci.update_attributes(configuration_item_attributes)
    if @ci.save
      flash[:notice] = "Item updated"
    else
      flash[:error] = "Error updating item"
    end
      redirect_to edit_admin_configuration_item_path(@ci)
  end

  private

  def configuration_item_attributes
    params.require(:configuration_item).permit(:key, :value, :name, :description)

  end
  
end

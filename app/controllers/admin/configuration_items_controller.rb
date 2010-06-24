class Admin::ConfigurationItemsController < Admin::BaseController
  
  def index
    @configuration_items = ConfigurationItem.all
  end
  
end

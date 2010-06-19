class Admin::CountriesController <  Admin::BaseController
  def index
    @countries = Country.all
  end
  
  def create
    @country = Country.create(params[:country])
    if @country.save
     # redirect_to admin_country_path(@country)
      redirect_to admin_countries_path
    else
      render :action => 'new'
    end
  end
  
  def new
    @country = Country.new
  end
  
  def edit
    @country = Country.find(params[:id])
  end
  
  
  def show
    @country = Country.find(params[:id])
  end
  
  def update
    @country = Country.find(params[:id])
    @country.update_attributes(params[:country])
    @country.save
  end
  
  def destroy
    @country = Country.find(params[:id])
    if @country.destroy
      redirect_to admin_countries_path
    end
  end
  
  
end

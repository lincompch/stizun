class Admin::TaxClassesController < Admin::BaseController
  
  def index
    @tax_classes = TaxClass.all
  end
  
  def create
    @tax_class = TaxClass.create(params[:tax_class])
    if @tax_class.save
      #redirect_to admin_tax_class_path(@tax_class)
      redirect_to admin_tax_classes_path
    else
      render :action => 'new'
    end
  end
  
  def new
    @tax_class = TaxClass.new
  end
  
  def edit
    @tax_class = TaxClass.find(params[:id])
  end
  
  
  def show
    @tax_class = TaxClass.find(params[:id])
  end
  
  def update
    @tax_class = TaxClass.find(params[:id])
    @tax_class.update_attributes(params[:tax_class])
    @tax_class.save
  end
  
  def destroy
    @tax_class = TaxClass.find(params[:id])
    if @tax_class.destroy
      redirect_to admin_tax_classes_path
    end
  end
  
end

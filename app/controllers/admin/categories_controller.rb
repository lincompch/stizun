class Admin::CategoriesController < Admin::BaseController
  
  
  def index
    @categories = Category.all
  end
  
  def new
    @category = Category.new
  end
  
  def create
    @category = Category.new
    @category.update_attributes(params[:category])
    if @category.save
      flash[:notice] = "Category created."
    else
      flash[:error] = "Error creating category."
    end
    redirect_to admin_categories_path
   
  end
  
  def edit
    @category = Category.find(params[:id])
  end
  
  def update
    @category = Category.find(params[:id])
    @category.update_attributes(params[:category])
    
    if @category.save
      flash[:notice] = "Category updated."
    else
      flash[:error] = "Error updating category."
    end    
    
    redirect_to admin_categories_path
  end
  
  def destroy
    @category = Category.find(params[:id])
    if @category.products.count > 0
      flash[:error] = "Can't destroy this category because it still contains products."
    else
      if @category.destroy
        flash[:notice] = "Category deleted."
      else
        flash[:error] = "Error deleting category."
      end    
    end
    redirect_to admin_categories_path
  end
  
  
end

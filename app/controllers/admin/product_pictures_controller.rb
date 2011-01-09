class Admin::ProductPicturesController < Admin::BaseController
  
  def index
    @product_pictures = Product.find(params[:product_id]).product_pictures
  end
  
  def show
    @product_picture = ProductPicture.find(params[:id])
  end
  
  def new
    @product = Product.find(params[:product_id])
    @product_pictures = @product.product_pictures
    @product_picture = @product.product_pictures.new
    render :layout => 'admin_blank'
  end
  
  
  def create
    @product = Product.find(params[:product_id])
    @product.product_pictures.create( params[:product_picture] )
    redirect_to edit_admin_product_path(@product)
  end
 
  def edit
    
  end
  
  def update  
    puts "da shit dates up"
    @product_picture = ProductPicture.find(params[:id])
    @product_picture.update_attributes(params[:product_picture])
    
    if params[:set_main_picture] == "true"
      @product_picture.set_main_picture
    end
    
    redirect_to :back
    
  end
                                    
  def destroy
  end
  
end

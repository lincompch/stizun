class Admin::ProductPicturesController < Admin::BaseController
  
  def index
    @product_pictures = Product.find(params[:product_id]).product_pictures
  end
  
  
  def show
    
  end
  
  def new
    @product = Product.find(params[:product_id])
    @product_pictures = @product.product_pictures
    @product_picture = @product.product_pictures.new
  end
  
  
  def create
    @product = Product.find(params[:product_id])
    @product.product_pictures.create( params[:product_picture] )
  end
 
  def edit
    
  end
  
  def update

  end
                                    
  def destroy
  end
  
end

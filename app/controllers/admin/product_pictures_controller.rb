class Admin::ProductPicturesController < Admin::BaseController

  def index
    @product_pictures = Product.find(params[:product_id]).product_pictures
  end

  def show
    @product_picture = ProductPicture.find(params[:id])
  end

  def new
    @product = Product.find(params[:product_id])
    @product_picture = @product.product_pictures.build
    render :layout => 'admin_blank'
  end


  def create
    @product = Product.find(params[:product_id])
    unless params[:product_picture][:file].blank?
      @product_picture = @product.product_pictures.build(params.permit![:product_picture])
      if @product_picture.save!
        flash[:info] = "Product picture created"
        redirect_to edit_admin_product_path(@product)
      else
        flash[:error] = "Error saving product picture"
        render :action => 'new', :layout => 'admin_blank'
      end
    end

  end

  def edit

  end

  def update
    puts "da shit dates up"
    @product_picture = ProductPicture.find(params[:id])
    @product_picture.update_attributes(params.permit![:product_picture])

    if params[:set_main_picture] == "true"
      @product_picture.set_main_picture
    end

    redirect_to :back
  end

  def destroy
    pp = ProductPicture.find(params[:id])
    product = pp.product

    # If there are at least two pictures, shift the main picture
    if pp.is_main_picture? and product.product_pictures.count > 1
      product.product_pictures.first.set_main_picture
    end
    pp.remove_file!
    pp.destroy

    redirect_to edit_admin_product_path(product)
  end

end


class ProductsController < ApplicationController

    def index
      # Resource was accessed in nested form through /categories/n/products
      if params[:category_id]
        @category = Category.find params[:category_id]
        @products = @category.products.available.paginate(:page => params[:page], :per_page => Product.per_page)
      else
        @products = Product.available.paginate(:page => params[:page], :per_page => Product.per_page)
      end
      
      if params[:q]
        if params[:q].length < 3
          flash[:error] = t('stizun.product.search_query_too_short')
        else
          @products = Product.available.search(params[:q], :page => params[:page], :per_page => Product.per_page)
        end
      end
      
      respond_to do |format|
      format.html
      format.csv do
       csv_string = FasterCSV.generate do |csv|
         csv << Product.csv_header
       @products.each do |p|
         csv << p.to_csv_array
         end
       end
       
       send_data csv_string,
                :type => 'text/csv; charset=utf-8; header=present',
                :disposition => "attachment; filename=lincomp_products.csv"
        end
      end
    end

    
    def show
      @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid product #{params[:id]}" )
      flash[:notice] = "Invalid product"
      redirect_to :action => :index
    end

    def edit
      # return an HTML form for editing the account
    end

    # PUT account_url
    def update
      # find and update the account
    end

    # DELETE account_url
    def destroy
      # delete the account
    end


      
end

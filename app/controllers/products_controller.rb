class ProductsController < ApplicationController

    def index
      # Resource was accessed in nested form through /categories/n/products
      ofield = "price" if params['ofield'].blank?
      odir = "ASC"  if params['odir'].blank?
      session['ofield'] = params['ofield'] if params['ofield']
      session['odir'] = params['odir'] if params['odir']
      
      ofield = session['ofield'] if session['ofield']
      odir = session['odir'] if session['odir']
      
      order_string = build_order_string(ofield, 
                                        odir)

      keyword = nil
      if params[:q]
        if params[:q].length < 3
          flash[:error] = t('stizun.product.search_query_too_short')
        else
          keyword = params[:q]
        end
      end
      
      with = {}
      conditions = {}
      
      if params[:category_id]
        @category = Category.find params[:category_id]
        with.merge!(:category_id => params[:category_id])
      end
      
      @products = Product.sphinx_available.search(keyword,
                                                  :conditions => conditions,
                                                  :with => with,
                                                  :order => order_string,
                                                  :page => params[:page], 
                                                  :per_page => Product.per_page)
      
      respond_to do |format|
      format.html
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

    def build_order_string(field = "price", dir = "ASC")
      field = "cached_taxed_price" if field == "price"
      return "#{field} #{dir}"
    end
      
end

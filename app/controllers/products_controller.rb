class ProductsController < ApplicationController

    def index
 
      order_string = build_order_string
      
      keyword = nil
      if params[:q]
        if params[:q].length < 3
          flash[:error] = t('stizun.product.search_query_too_short')
        else
          keyword = params[:q]
        end
      end
      
      keyword = Riddle.escape(keyword) unless keyword.nil?
      
      with = {}
      conditions = {}
      
      if params[:category_id]
        @category = Category.find params[:category_id]
        with.merge!(:category_id => params[:category_id])
      end
      
      @products = Product.sphinx_available.sphinx_visible.search(keyword,
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
        
      begin
        @product = Product.find(params[:id])
        unless @product.supplier.nil? or @product.supplier.utility_class_name.blank?
          begin
            require Rails.root + "lib/#{@product.supplier.utility_class_name.underscore}"
            @changes = @product.supplier.utility_class_name.constantize.live_update(@product)
            # TODO: Create something like @product.was_live_updated? so that these things
            #       are handled centrally without duplication in the model.
            if @changes.is_a?(Array) and !@changes.empty?
              @product.reload
            end
          rescue LoadError => e
            logger.error "Could not require lib/#{@product.supplier.utility_class_name.underscore} for live update: #{e.message}"
          end          
        end
        session[:return_to] = product_path(@product)
        require Rails.root + "lib/piwik"
        @piwik = piwik_set_ecommerce_view(@product.id, @product.name, @product.categories.collect(&:name)[0..4].as_json, @product.taxed_price.rounded.to_f)

        @title = "Lincomp: #{@product.manufacturer} - #{@product.name} - #{@product.manufacturer_product_code}"
      rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid product #{params[:id]}" )
        flash[:notice] = "Invalid product"
        redirect_to :action => :index
      end     
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

    def build_order_string
      # Fields for ordering (order field, order direction)   
      unless params['odir'].blank?
        session['odir'] = params['odir']
      else
        params['odir'] = "ASC"
      end
      
      if session['odir']
        odir = session['odir']
        params['odir'] = odir
      end
      
      unless params['ofield'].blank?
        session['ofield'] = params['ofield']
      else
        params['ofield'] = "price"
      end
      
      if session['ofield']
        ofield = session['ofield']
        params['ofield'] = ofield 
      end
            
      ofield = "cached_taxed_price" if params['ofield'] == "price"
      odir = params['odir']
      return "#{ofield} #{odir}" 
    end
    
    def subscribe
      @product = Product.find(params[:id])
      @notification = Notification.new(:product => @product, :user => current_user, :email => params[:email], :active => false)
      respond_to do |format|
        if @notification.save
          format.html{flash[:notice] = "Preis-Updates abonniert"
          redirect_to session[:return_to]}
        else
          format.html{flash[:error] = "Das ist keine E-Mail-Adresse"
          redirect_to session[:return_to]}
        end
      end
    end
      
end

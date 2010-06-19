class Admin::ShippingCostsController < Admin::BaseController
  # GET /shipping_costs
  # GET /shipping_costs.xml
  def index
    @shipping_costs = ShippingCost.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shipping_costs }
    end
  end

  # GET /shipping_costs/1
  # GET /shipping_costs/1.xml
  def show
    @shipping_cost = ShippingCost.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shipping_cost }
    end
  end

  # GET /shipping_costs/new
  # GET /shipping_costs/new.xml
  def new
    @shipping_cost = ShippingCost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shipping_cost }
    end
  end

  # GET /shipping_costs/1/edit
  def edit
    @shipping_cost = ShippingCost.find(params[:id])
  end

  # POST /shipping_costs
  # POST /shipping_costs.xml
  def create
    @shipping_cost = ShippingCost.new(params[:shipping_cost])

    respond_to do |format|
      if @shipping_cost.save
        flash[:notice] = 'ShippingCost was successfully created.'
        format.html { redirect_to( admin_shipping_cost_path(@shipping_cost) ) }
        format.xml  { render :xml => @shipping_cost, :status => :created, :location => @shipping_cost }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shipping_cost.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shipping_costs/1
  # PUT /shipping_costs/1.xml
  def update
    @shipping_cost = ShippingCost.find(params[:id])

    respond_to do |format|
      if @shipping_cost.update_attributes(params[:shipping_cost])
        flash[:notice] = 'ShippingCost was successfully updated.'
        format.html { redirect_to(admin_shipping_cost_path(@shipping_cost)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shipping_cost.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_costs/1
  # DELETE /shipping_costs/1.xml
  def destroy
    @shipping_cost = ShippingCost.find(params[:id])
    @shipping_cost.destroy

    respond_to do |format|
      format.html { redirect_to(admin_shipping_costs_url) }
      format.xml  { head :ok }
    end
  end
end

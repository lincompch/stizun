class Admin::ShippingCalculatorsController < Admin::BaseController
  # GET /admin/shipping_calculators
  def index
    @shipping_calculators = ShippingCalculator.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/shipping_calculators/1
  def show
    @shipping_calculator = ShippingCalculator.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/shipping_calculators/new
  def new
    @shipping_calculator = ShippingCalculator.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/shipping_calculators/1/edit
  def edit
    @shipping_calculator = ShippingCalculator.find(params[:id])
  end

  # POST /admin/shipping_calculators
  def create
    klass = params[:shipping_calculator_class]
    
    if klass == "ShippingCalculatorBasedOnWeight"
      @shipping_calculator = ShippingCalculatorBasedOnWeight.new(params[:shipping_calculator])
    else
      @shipping_calculator = ShippingCalculator.new(params[:shipping_calculator])
    end
  
    respond_to do |format|
      if @shipping_calculator.save
        format.html { redirect_to polymorphic_path(@shipping_calculator), notice: 'Shipping calculator was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /admin/shipping_calculators/1
  def update
    @shipping_calculator = ShippingCalculator.find(params[:id])
    config = params[:shipping_calculator][:configuration]
    unless config.empty? or config.blank?
      if @shipping_calculator.class.name == "ShippingCalculatorBasedOnWeight"
        (0..config[:weight_min].count).each do |n|
          @shipping_calculator.configuration.weight_min = config[:weight_min][n]
          @shipping_calculator.configuration.weight_max = config[:weight_max][n]
          @shipping_calculator.configuration.price = config[:price][n]          
        end
      end
    end
    
    @shipping_calculator.name = params[:shipping_calculator][:name]

    respond_to do |format|
      #if @shipping_calculator.update_attributes(params[:shipping_calculator])
      if @shipping_calculator.save
        format.html { redirect_to url_for(action: 'show', controller: 'shipping_calculators', id: @shipping_calculator), notice: 'Shipping calculator was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /admin/shipping_calculators/1
  def destroy
    @shipping_calculator = ShippingCalculator.find(params[:id])
    @shipping_calculator.destroy

    respond_to do |format|
      format.html { redirect_to admin_shipping_calculators_url }
    end
  end
end

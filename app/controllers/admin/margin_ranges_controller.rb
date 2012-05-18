class Admin::MarginRangesController < Admin::BaseController
  # GET /margin_ranges
  # GET /margin_ranges.xml
  def index

    conditions = {:supplier_id => nil, :product_id => nil}
    if params[:supplier_id]
      conditions.merge!(:supplier_id => params[:supplier_id])
      @supplier = Supplier.find(params[:supplier_id])
    end

    if params[:product_id]
      conditions.merge!(:product_id => params[:product_id])
      @product = Supplier.find(params[:supplier_id])
    end

    @margin_ranges = MarginRange.where(conditions).order("start_price ASC, end_price ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @margin_ranges }
    end
  end

  # GET /margin_ranges/new
  # GET /margin_ranges/new.xml
  def new
    conditions = {}
    if params[:supplier_id]
      conditions.merge!(:supplier_id => params[:supplier_id])
      @supplier = Supplier.find(params[:supplier_id])
    end

    if params[:product_id]
      conditions.merge!(:product_id => params[:product_id])
      @product = Supplier.find(params[:supplier_id])
    end

    @margin_range = MarginRange.new(conditions)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @margin_range }
    end
  end

  # GET /margin_ranges/1/edit
  def edit
    @margin_range = MarginRange.find(params[:id])
    @product = @margin_range.product if @margin_range.product
    @supplier = @margin_range.supplier if @margin_range.supplier
  end

  # POST /margin_ranges
  # POST /margin_ranges.xml
  def create
    @margin_range = MarginRange.new(params[:margin_range])

    respond_to do |format|
      if @margin_range.save
        flash[:notice] = 'MarginRange was successfully created.'
        format.html { redirect_to(admin_margin_ranges_path(:supplier_id => @margin_range.supplier_id, :product_id => @margin_range.product_id)) }
        format.xml  { render :xml => @margin_range, :status => :created, :location => @margin_range }
      else
        format.html { render :action => "new", :supplier_id => @margin_range.supplier_id, :product_id => @margin_range.product_id }
        format.xml  { render :xml => @margin_range.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /margin_ranges/1
  # PUT /margin_ranges/1.xml
  def update
    @margin_range = MarginRange.find(params[:id])
    @product = @margin_range.product if @margin_range.product
    @supplier = @margin_range.supplier if @margin_range.supplier

    respond_to do |format|
      if @margin_range.update_attributes(params[:margin_range])
        flash[:notice] = 'MarginRange was successfully updated.'
        format.html { redirect_to(admin_margin_ranges_path(:supplier_id => @margin_range.supplier_id, :product_id => @margin_range.product_id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :supplier_id => @margin_range.supplier_id, :product_id => @margin_range.product_id }
        format.xml  { render :xml => @margin_range.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /margin_ranges/1
  # DELETE /margin_ranges/1.xml
  def destroy
    @margin_range = MarginRange.find(params[:id])
    @margin_range.destroy

    respond_to do |format|
      format.html { redirect_to(admin_margin_ranges_url(:supplier_id => @margin_range.supplier_id, :product_id => @margin_range.product_id)) }
      format.xml  { head :ok }
    end
  end
end

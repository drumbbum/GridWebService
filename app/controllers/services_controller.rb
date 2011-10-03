class ServicesController < ApplicationController
  before_filter :logged_in
  def data
    @query = Query.new
    @discActions = DiscoveryActions.new
    $DATA_SERVICES ||= @discActions.getDataServices
    @services = $DATA_SERVICES
    @dataServices = $DATA_SERVICES
  end

  def analytical
     @discActions = DiscoveryActions.new
     $ANALYTICAL_SERVICES ||= @discActions.getAnalyticalServices
     @services = $ANALYTICAL_SERVICES
  end
  
  def search
    @query = Query.new
    @discActions = DiscoveryActions.new
    @services = @discActions.searchServices(params[:term])
    $DATA_SERVICES ||= @discActions.getDataServices
    @dataServices = $DATA_SERVICES
  end

  def view
    if params[:analytical_button]
      respond_to do |format|
        format.html { redirect_to(services_analytical_path) }
        format.xml  { render :xml => @service }
      end
    end
    
    if params[:data_button]
      respond_to do |format|
        format.html  {redirect_to :controller => "services", :action => "data"}
        format.xml  { render :xml => @service }
      end
    end
    
    if params[:search_button]
      respond_to do |format|
        format.html { redirect_to :controller => "services", :action => "search", :term => params[:term]}
        format.xml  { render :xml => @service }
      end
    end
  end
  
#  def query
#    @query = Query.new
#    params.each do |h| 
#      if h.to_s.first(4).eql?("http")
#        @query[:endpoint] = h
#      end
#    end
#    respond_to do |format|
#      format.html { redirect_to :controller => "queries", :action => "create", '_method' => :post }
#      format.xml  { render :xml => @service }
#    end
#  end
  
end

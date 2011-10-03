class QueriesController < ApplicationController
  before_filter :logged_in
  # GET /queries
  # GET /queries.xml
  def index
    @queries = Array.new
    Query.all.each do |query|
      if query.user_id == current_user.id
        @queries << query
      end
    end
    @endpoints = Set.new
    @queries.each do |query|
      @endpoints << query.endpoint
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @queries }
    end
  end
  
  # GET /queries/1
  # GET /queries/1.xml
  def show
    @query = Query.find(params[:id])
    client = GridClientClass.new
    @modifier = @query.modifier
    @attributes = Array.new
    
    @cql1Result = client.getCQL1QueryXML(getGlobusCred, @query)
    puts @cql1Result
    
    @cql2Result = client.getCQL2QueryXML(getGlobusCred, @query)
    puts @cql2Result
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @query }
    end
  end
  
  # GET /queries/new
  # GET /queries/new.xml
  def new
    @query = Query.new
    @discActions = DiscoveryActions.new
    $DATA_SERVICES ||= @discActions.getDataServices
    @services = $DATA_SERVICES
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @query }
    end
  end
  
  # GET /queries/1/edit
  def edit
    client = GridClientClass.new
    @query = Query.find(params[:id])
    @service = Service.new
    @service.address = @query.endpoint
    @objects = client.displayDomainObjectNames(@service.address)
    @attributes = client.displayDomainObjectAttributes(@service.address, @query.object)
  end
  
  # GET /queries/xml
  def xml
    @query = Query.new
    @endpoint = params[:url]
    @xml = params[:xml]
    @version = params[:version]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @query }
    end
  end
  
  def xmlResult
    @endpoint = params[:url]
    @xml = params[:xml]
    @version
    if params[:version].eql?("true")
      @version = params[:version]
    end
    
    dataServiceActions = DataServiceActions.new
    if client = dataServiceActions.getClient(@endpoint, getGlobusCred)
      begin
        query = dataServiceActions.constructXmlQuery(client, @xml, @version)
        puts "Query Created Successfullly"
      rescue
        redirect_to(query_xml_path(:url => params[:url], :xml => params[:xml]), :notice => 'Invalid XML')
        return
      end      
      if @version
        @result = dataServiceActions.runQuery(client, query)
        @rows = processResultXML(@result, false)
      else
        @result = dataServiceActions.runCQL2Query(client, query)
        if @result.eql?("org.apache.axis.AxisFault")
          puts "AxisFault Error"
          redirect_to(query_xml_path(:url => params[:url], :xml => params[:xml]), :notice => 'Service Does Not Support CQL2 Queries')
          return 
        end
        @rows = processResultXML(@result, true)
      end
    else
      redirect_to(query_xml_path(:url => params[:url]), :notice => 'Invalid URL Provided')
      return
    end
    
    if !@rows.empty?
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @query }
      end
    else
      respond_to do |format|      
        flash[:notice] = "No Results Found"
        format.html 
        format.xml  { render :xml => @query }
      end
    end   
  end
  
  # POST /queries
  # POST /queries.xml
  def create   
    @service = Service.new
    
    # Redirect from Service Selection
    if !params[:query]
      puts "Redirect from Service Selection"
      $DATA_SERVICES.each do |serv|
        if params.key?(serv.address)
          puts serv.address
          params[:service_button] = true
          @service.address = serv.address
        end
      end
    end
    
    if params[:service_button]
      puts "SERVICE BUTTON PRESSED"
      client = GridClientClass.new
      @query = Query.new(params[:query])
      @service.address ||= params[:query][:endpoint]
      @objects = client.displayDomainObjectNames(@service.address)
      params[:endpoint] = @service.address
      respond_to do |format|
        format.html { render :action => "object" }
        format.xml  { render :xml => @query }
      end
      
    elsif params[:object_button]
      puts "OBJECT BUTTON PRESSED"
      client = GridClientClass.new
      @query = Query.new
      @service.address = params[:endpoint]
      @query.object = params[:Object]
      @attributes = client.displayDomainObjectAttributes(@service.address, @query.object)
      @dmAssociations = client.displayDomainModelAssociations(@service.address)
      @associations = Association.find_all_by_cql_object_id(CqlObject.find_by_objectName(params[:Object]))
      params[:obj] = params[:Object]
      respond_to do |format|       
        format.html { render :action => "parameters" }
        format.xml  { render :xml => @queries }
      end
    elsif params[:change_service_button]
      puts "CHANGE SERVICE BUTTON PRESSED"
      # Start a new query
      redirect_to(new_query_path)
      
    elsif params[:change_object_button]
      puts "CHANGE OBJECT BUTTON PRESSED"
      # Jump to object.html.erb to change object value
      client = GridClientClass.new
      @query = Query.new
      @service.address = params[:endpoint]
      @objects = client.displayDomainObjectNames(@service.address)
      respond_to do |format|
        format.html { render :action => "object" }
        format.xml  { render :xml => @query }
      end     
    elsif params[:association_button]
      puts "SAVING ASSOCIATION QUERY"
      @query = Query.new(params[:query])
      @query.predicate_id = params[:predicate_id][0]
      @query.value = params[:value]
      @query.user_id = current_user.id
      #      @query.modifier = "association"
      respond_to do |format|  
        if @query.save
          format.html { redirect_to(@query, :notice => 'Query was successfully created.') }
          format.xml  { render :xml => @query, :status => :created, :location => @query }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @query.errors, :status => :unprocessable_entity }
        end
      end
    elsif params[:xml_query]
      redirect_to(query_xmlResult_path(:url => params[:url], :xml => params[:xml], :version => params[:version]))
    else
      puts "SAVING QUERY OBJECT"
      puts params[:obj]
      @query = Query.new(params[:query])
      @query.object = params[:obj]
      @query.endpoint = params[:endpoint]
      @query.user_id = params[:user_id]
      
      # Construct Modifiers
      String mod = params[:modifier]
      if mod.eql?("distinct_attribute")
        attributes = params[:DA].join(',') 
        
      elsif mod.eql?("selected_attributes")
        attributes = params[:SA].join(',')
      end
      @query.modifier = mod
      @query.term = attributes
      
      respond_to do |format|
        if @query.save
          format.html { redirect_to(@query, :notice => 'Query was successfully created.') }
          format.xml  { render :xml => @query, :status => :created, :location => @query }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @query.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  # PUT /queries/1
  # PUT /queries/1.xml
  def update
    if params[:change_button]
      redirect_to(query_service_path)
    else
      String mod = params[:modifier]
      @query = Query.find(params[:id])      
      @query.modifier = mod
      
      # Construct Modifiers
      if mod.eql?("distinct_attribute")
        @query.term = params[:DA].join(',')
        
      elsif mod.eql?("selected_attributes")
        @query.term = params[:SA].join(',')
        
      elsif mod.eql?("object") || mod.eql?("count")
        @query.term = nil
      else
        puts "UPDATING ASSOCIATION QUERY"
        @query = Query.new(params[:query])
        @query.modifier = "association"
        @query.predicate_id = params[:predicate_id][0]
        @query.value = params[:value]
        @query.user_id = current_user.id      
      end
      
      respond_to do |format|
        if @query.update_attributes(@query)
          format.html { redirect_to(@query, :notice => 'Query was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @query.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  # DELETE /queries/1
  # DELETE /queries/1.xml
  def destroy
    @query = Query.find(params[:id])
    @query.destroy
    
    respond_to do |format|
      format.html { redirect_to(queries_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /queries/1/result
  def result
    puts "RESULT CALLED"
    @query = Query.find(params[:id])
    
    client = GridClientClass.new
    @result = client.queryDataService(getGlobusCred, @query)
    @rows = self.processResultXML(@result, false)    
    respond_to do |format|
      if @rows.drop(1).length > 0
        format.html 
        format.xml  { render :xml => @query }
      else
        flash[:notice] = "No Results Found"
        format.html
        format.xml {render :xml => @query }
      end
    end
  end
  
  # POST /queries/predicate
  def predicate
    puts "PREDICATE CALLED!"
    if params[:id]
      @query = Query.find(params[:id])
    else
      @query = Query.new
      @query.object = params[:Object]
      @query.endpoint = params[:endpoint]
      @query.user_id = current_user.id
    end
    @query.modifier = "association"
    @query.term = params[:association] + "," + params[:attribute]
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @queries }
    end
  end
  
  def processResultXML(xml, cql2)
    require "rexml/document" 
    rows = Array.new
    values = Array.new
    unless xml.nil?
    if !xml.empty?
      xml = "<EOF>" + xml + "</EOF>"     
      doc = REXML::Document.new(xml)
      unless doc.nil?
        attributes = Array.new
        all_elements = doc.elements.first
        ns = all_elements.first.prefix
        puts ns
        if REXML::XPath.first(doc, "//" + ns + ":Attribute")
          puts "AttributeResult"
          array = REXML::XPath.match(doc, "//" + ns + ":Attribute")
          attributes = REXML::XPath.match(doc, "//" + ns + ":Attribute/attribute::name").join('~').split('~').uniq
          rows << attributes
          array.each do |element|
            values << element.attributes["value"]
          end
          while !values.empty? do
            rows << values.slice!(0, attributes.size)
          end
          
        elsif REXML::XPath.first(doc, "//" + ns + ":AggregationResult")
          puts "AggregationResult"
          result = REXML::XPath.first(doc, "//" + ns + ":AggregationResult")
          if result.attributes["aggregation"].eql?("COUNT")
            rows << ["Count"]
            rows << [result.attributes["value"].to_s]
          else
            rows << ["Attribute Name", "Value", "Aggregation"]
            rows << [result.attributes["attributeName"], result.attributes["value"], result.attributes["aggregation"]]
          end
        elsif REXML::XPath.first(doc, "//" + ns + ":CQLCountResult")
          puts "CQL Count Result"
          result = REXML::XPath.first(doc, "//" + ns + ":CQLCountResult")
          rows << ["Count"]
          rows << [result.attributes["count"].to_s]
        elsif REXML::XPath.first(doc, "//" + ns + ":ObjectResult")
          puts "ObjectResult Parsing"
          firstObjectResult = REXML::XPath.first(doc, "//" + ns + ":ObjectResult")
          all_elements = REXML::XPath.match(doc, "//" + firstObjectResult.elements.first.name)
          
          # Get max number of Attributes
          all_elements.each do |element|
            currentAttributes = Array.new
            atts = element.attributes
            atts.each {|key, value|          
              unless key.include?("xmlns")
                currentAttributes << key
              end
            }
            if currentAttributes.size > attributes.size
              attributes = currentAttributes
            end
          end
          rows << attributes
          
          # Get Values of each Result
          all_elements.each do |element|
            values = Array.new
            attributes.each do |att|
              values << element.attributes[att]
            end
            rows << values
          end
          
        elsif REXML::XPath.first(doc, "//" + ns + ":CQLQueryResults")
          puts "Empty CQLQueryResults"
        else
          puts "Did not match"
          single = all_elements.first
          
          # Get max number of Attributes
          while single do
            currentAttributes = Array.new
            atts = single.attributes
            atts.each {|key, value|          
              unless key.include?("xmlns")
                currentAttributes << key
              end
            }
            if currentAttributes.size > attributes.size
              attributes = currentAttributes
            end
            single = single.next_element
          end
          rows << attributes
          
          # Get Values of each Result
          single = all_elements.first
          while single do
            values = Array.new
            attributes.each do |att|
              values << single.attributes[att]
            end
            single = single.next_element
            rows << values
          end         
        end
      end
    end
    end
    return rows
  end
  
end
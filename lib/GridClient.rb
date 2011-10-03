require "java"

Dir["./lib/jars/caGrid/*.jar"].each {|file|
  require file
#  puts file
}
Dir[ENV['GLOBUS_LOCATION'] + "/lib/*.jar"].each {|file|
  if !file.end_with?("xercesImpl.jar")
  require file
#  puts file
  end
}
Dir["./lib/*.rb"].each {|file|
  if !file.end_with?("GridClient.rb")
    require file
    puts file
  end
}
$CLASSPATH << Rails.root.to_s + "/lib"
#puts $CLASSPATH

include_class "java.util.Properties"
include_class "java.io.FileInputStream"

include_class "org.apache.axis.message.addressing.EndpointReferenceType"

CLIENT_PROPERTIES = Rails.root.to_s + "/lib/conf/client.properties"
SYNC_DESCRIPTION  = "sync.description"
DEFAULT_DORIAN_SERVICE_URL_PROP = "default.dorian.service.url"

module Types
  include_package "org.apache.axis.types"
end

class GridClientClass
  def initialize()
    @props = readProperties()
  end

  def readProperties()
    begin
      properties = Properties.new
      properties.load(FileInputStream.new(CLIENT_PROPERTIES))
    rescue
      puts "Exception while accessing " + CLIENT_PROPERTIES + " : " + $!
    end
    return properties;
  end
  
  def periodicPopulateDatabase
    t = Thread.new do
      while true do
        self.populateDatabase
        sleep(60*60)
      end
    end
  end
  
  def populateDatabase
    puts "Populating DB"
    @discActions = DiscoveryActions.new
    $DATA_SERVICES = @discActions.getDataServices
    $DATA_SERVICES.each do |service|
      unless Endpoint.find_by_address(service.address)
        Endpoint.loadEndpoint(service)
      end
    end
    puts "Finished Population of DB"
  end

  def periodicSync
    t = Thread.new do
      while true do
        self.syncTrust
        sleep(15 * 60)
      end
    end
  end

  def syncTrust
    puts "Synchronize Trust Fabric"
    result = SyncGridTrust.synchronizeOnce(@props.getProperty(SYNC_DESCRIPTION))
    if result
      puts "Synchronize Complete."
    else
      puts "Failed to Synchronize"
    end

  end
  
    def getAuthServiceURL
    puts "Getting Trusted Identity Providers"
    userActions = UserActions.new(@props.getProperty(DEFAULT_DORIAN_SERVICE_URL_PROP))
    return userActions.getAuthServiceURL
  end
  
  def loginUser(username, password, url)
    puts "Login to the Grid"
    begin
      userActions = UserActions.new(@props.getProperty(DEFAULT_DORIAN_SERVICE_URL_PROP))
      @cred = userActions.loginUser(username, password, url)
    rescue
      puts "Error: " + $!
    end   
  end
  
    def displayDomainObjectNames(epr)
    begin
      dmActions = DomainModelActions.new(epr)
      objects = Array.new
      dmActions.umlClassCollection.each { |uml|
        objectName = uml.getPackageName + "." + uml.getClassName
        objects << objectName
      }
     
      return objects
    rescue
      puts "Error in displayDomainObjectNames: " + $!
    end
  end
  
  def displayDomainObjectAttributes(epr, object)
    begin
      dmActions = DomainModelActions.new(epr)
      umlClass = dmActions.getUMLClass(object)
      return dmActions.getObjectAttributes(umlClass)
    rescue
      puts "Error in displayDomainObjectAttributes: " + $!
    end
  end
  
  def getDomainObjectAssociations(objectName, dmAssociations)
    dmAssociations.each do |dma|
      if objectName.eql?(dma[0])
        return dma
      end
    end
  end

  
  def displayDomainObjectAssociations(epr, object)
    begin
      dmActions = DomainModelActions.new(epr)
      umlClass = dmActions.getUMLClass(object)
      associationObjects = dmActions.getUMLClassAssociation(umlClass)
      return associationObjects     
    rescue
      puts "Error in displayDomainObjectAssociations: " + $!
    end
  end
  
  # Returns Array of triples (ObjectName, Attributes, Arr(Associations))
  def displayDomainModelAssociations(epr)
    begin
      dmActions = DomainModelActions.new(epr)
      dmAssociations = Array.new
      dmActions.umlClassCollection.each do |umlClass|
        objectName = dmActions.getObjectName(umlClass)
        attributes = dmActions.getObjectAttributes(umlClass)
        associations = dmActions.getUMLClassAssociation(umlClass)
        dmAssociations << [objectName, attributes, associations]
      end
      return dmAssociations
    rescue
      puts "Error in displayDomainModelAssociations: " + $!
    end
  end
  
  def queryDataService(cred, dbQuery)
    dataServiceActions = DataServiceActions.new
    client = dataServiceActions.getClient(dbQuery.endpoint, cred)
    query = dataServiceActions.constructQuery(client, dbQuery)
    result = dataServiceActions.runQuery(client, query)
    
    return result
  end
  
  def getCQL1QueryXML(cred, dbQuery)
    dataServiceActions = DataServiceActions.new
    client = dataServiceActions.getClient(dbQuery.endpoint, cred)
    query = dataServiceActions.constructQuery(client, dbQuery)
    result = dataServiceActions.getCQLQueryXML(query)
    
    return result
  end
  
  def getCQL2QueryXML(cred, dbQuery)
    dataServiceActions = DataServiceActions.new
    client = dataServiceActions.getClient(dbQuery.endpoint, cred)
    query = dataServiceActions.constructQuery(client, dbQuery)
     
#    endpoint = EndpointReferenceType.new(Types::URI.new(query.endpoint.to_java_string))
#    domainModel = MetadataUtils.getDomainModel(endpoint)
    dmActions = DomainModelActions.new(dbQuery.endpoint)
    
    result = dataServiceActions.getCQL2QueryXML(dmActions.domainModel, query)

    return result
  end

end
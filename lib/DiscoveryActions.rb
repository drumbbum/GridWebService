include_class "gov.nih.nci.cagrid.discovery.client.DiscoveryClient"
include_class "gov.nih.nci.cagrid.metadata.MetadataUtils"

DEFAULT_URL = "http://index.training.cagrid.org:8080/wsrf/services/DefaultIndexService"

class DiscoveryActions
  @discClient = DiscoveryClient.new

  begin
    def initialize()
      @discClient = DiscoveryClient.new(DEFAULT_URL)
    end
  rescue
    puts "Thrown MalformedURIException"
    raise
  end
  
  def getServices
    return processResults(@discClient.getAllServices(true))
  end
  
  
  def getDataServices
    return processResults(@discClient.getAllDataServices())
  end
  
  def getAnalyticalServices
    return processResults(@discClient.getAllAnalyticalServices())
  end
  
  def searchServices(searchTerm)
    puts "Searching for '" + searchTerm + "'"
    return processResults(@discClient.discoverServicesBySearchString(searchTerm))
  end
  
  def processResults(results)
    serviceArray = Array.new
    unless results.nil?
      results.each { |serv|
        @service = Service.new
        @service.address = serv.getAddress().toString()
        begin
          metadata = MetadataUtils.getServiceMetadata(serv)   
          @service.description = metadata.getServiceDescription().getService().getDescription()
          @service.name = metadata.getHostingResearchCenter().getResearchCenter().getDisplayName()
          serviceArray << @service
        rescue Exception
          puts "MetadataUtils Error: ", $!
        end
      } 
    end
    return serviceArray
  end
end

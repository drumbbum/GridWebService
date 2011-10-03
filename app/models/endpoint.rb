class Endpoint < ActiveRecord::Base
  has_many :cql_objects
  
  def self.loadEndpoint(service)  
    @endpoint = Endpoint.new
    @endpoint.name = service.name
    @endpoint.address = service.address
    @endpoint.description = service.description
    if @endpoint.save
      puts "Saved Endpoint: " + @endpoint.address
      CqlObject.loadCqlObjects(Endpoint.find_by_address(@endpoint.address).id)
    else
      puts "Error Saving Endpoint: " + @endpoint.address
    end    
  end
  
  def remove
    cqlObjects = CqlObject.find_all_by_endpoint_id(self.id)
    cqlObjects.each do |cqlObject|
      cqlObject.remove
    end
    self.delete
  end
end

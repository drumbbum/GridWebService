class CqlObject < ActiveRecord::Base
  belongs_to :endpoint, :foreign_key => :endpoint_id
  has_many :attributes, :dependent => :delete_all
  has_many :associations, :dependent => :delete_all
  
  def self.loadCqlObjects(endpoint_id)
    @endpoint = Endpoint.find_by_id(endpoint_id)   
    dmActions = DomainModelActions.new(@endpoint.address)
    dmActions.umlClassCollection.each do |umlClass|       
      unless CqlObject.find_by_objectName(dmActions.getObjectName(umlClass))
        @cqlObject = CqlObject.new
        @cqlObject.objectName = dmActions.getObjectName(umlClass)
        @cqlObject.refid = umlClass.getId
        @cqlObject.endpoint_id = endpoint_id
        if @cqlObject.save
          puts "Saved cqlObject: " + @cqlObject.objectName
          Association.loadAssociations(dmActions, umlClass)
          Attribute.loadAttributes(dmActions, umlClass)
        else
          puts "Error Saving cqlObject: " + @cqlObject.objectName
        end
      end
    end
  end
  
  def remove
    associations = Association.find_all_by_cql_object_id(self.id)
    associations.each do |association|
      association.delete
    end
    attributes = Attribute.find_all_by_cql_object_id(self.id)
    attributes.each do |attribute|
      attribute.delete
    end
    self.delete
  end
end

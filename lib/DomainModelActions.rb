class DomainModelActions
  include_class "org.apache.axis.message.addressing.EndpointReferenceType"
  
  module Types
    include_package "org.apache.axis.types"
  end
  attr_accessor :endpoint, :domainModel, :umlClassCollection, :umlAssociationCollection
  
  def initialize(epr)
    @endpoint = EndpointReferenceType.new(Types::URI.new(epr.to_java_string))
    @domainModel = MetadataUtils.getDomainModel(endpoint)
    @umlClassCollection = domainModel.getExposedUMLClassCollection().getUMLClass()
    @umlAssociationCollection = domainModel.getExposedUMLAssociationCollection.getUMLAssociation()
  end
  
  def getUMLClass(object)
    @umlClassCollection.each { |uml|
      objectName = uml.getPackageName + "." + uml.getClassName
      if objectName.eql?(object)
        return uml
      end
    }
  end
  
  def getObjectNameFromRefid(refid)
    begin
      @umlClassCollection.each do |umlClass|
        if umlClass.getId.eql?(refid)
          return getObjectName(umlClass)
        end
      end
    rescue
      puts "Error in getObjectNameFromRefid: " + $!
    end
  end
  
  def getObjectName(umlClass)
    return umlClass.getPackageName + "." + umlClass.getClassName
  end
  
  def getObjectAttributes(umlClass)
    attributes = Array.new
    umlAttributeCollection = umlClass.getUmlAttributeCollection
    unless umlAttributeCollection.nil?
      attributesObjects = umlAttributeCollection.getUMLAttribute    
      attributesObjects.each { |att|
        attributes << att.getName
      }
    end
    return attributes
  end
  
  # Returns Array of tuples (Object_Name, Object_Role_Name)
  def getUMLClassAssociation(umlClass)
    begin
      associationObjects = Array.new
      @umlAssociationCollection.each do |uml|
        if  umlClass.getId.eql?(uml.getSourceUMLAssociationEdge.getUMLAssociationEdge.getUMLClassReference.getRefid)
          refid = uml.getTargetUMLAssociationEdge.getUMLAssociationEdge.getUMLClassReference.getRefid
          roleName = uml.getTargetUMLAssociationEdge.getUMLAssociationEdge.getRoleName
          associationObjects << [ getObjectNameFromRefid(refid), roleName ]
        elsif uml.isBidirectional()
          if umlClass.getId.eql?(uml.getTargetUMLAssociationEdge.getUMLAssociationEdge.getUMLClassReference.getRefid)
            refid = uml.getSourceUMLAssociationEdge.getUMLAssociationEdge.getUMLClassReference.getRefid
            roleName = uml.getSourceUMLAssociationEdge.getUMLAssociationEdge.getRoleName
            associationObjects << [ getObjectNameFromRefid(refid), roleName ]
          end
        end     
      end  
      return associationObjects
    rescue
      puts "Error in getUMLClassAssociation: " + $!
    end
  end  
  
  def getAssociations
    
  end
end
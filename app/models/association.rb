class Association < ActiveRecord::Base
  belongs_to :cql_object, :foreign_key => :cql_object_id
  
  def self.loadAssociations(dmActions, umlClass)
    associations = dmActions.getUMLClassAssociation(umlClass)
    cqlObject_id = CqlObject.find_by_objectName(dmActions.getObjectName(umlClass)).id
    associations.each do |asc|
      unless Association.find_by_objectName_and_object_id(asc[0], cqlObject_id)           
        @association = Association.new
        @association.objectName = asc[0]
        @association.roleName = asc[1]
        @association.cql_object_id = cqlObject_id
        if @association.save
          puts "Saved Association: " + @association.objectName + " " + @association.roleName
        else
          puts "Error Saving Association: " + @association.objectName + " " + @association.roleName
        end
      end
    end
  end
  
  def self.find_by_objectName_and_object_id(objectName, cqlObject_id)
    associations = Association.find_all_by_cql_object_id(cqlObject_id)
    associations.each do |asc|
      if asc.objectName.eql?(objectName)
        return asc
      end
    end
    return
  end
end

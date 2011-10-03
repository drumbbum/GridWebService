class Attribute < ActiveRecord::Base
  belongs_to :cql_object, :foreign_key => :cql_object_id
  
  def self.loadAttributes(dmActions, umlClass)   
    attributes = dmActions.getObjectAttributes(umlClass)
    cqlObject_id = CqlObject.find_by_objectName(dmActions.getObjectName(umlClass)).id
    attributes.each do |att|
      unless Attribute.find_by_name_and_object_id(att, cqlObject_id)
        @attribute = Attribute.new
        @attribute.name = att
        @attribute.cql_object_id = cqlObject_id
        if @attribute.save
          puts "Saved Attribute: " + @attribute.name
        else
          puts "Error Saving Attribute: " + @attribute.name
        end
      end
    end
  end
  
  def self.find_by_name_and_object_id(name, cqlObject_id)
    attributes = Attribute.find_all_by_cql_object_id(cqlObject_id)
    attributes.each do |att|
      if att.name.eql?(name)
        return att
      end
    end
    return
  end
end

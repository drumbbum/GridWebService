include_class "gov.nih.nci.cagrid.cqlresultset.CQLQueryResults"
include_class "gov.nih.nci.cagrid.data.client.DataServiceClient"
include_class "gov.nih.nci.cagrid.data.utilities.CQLQueryResultsIterator"
include_class "gov.nih.nci.cagrid.common.Utils"
include_class "gov.nih.nci.cagrid.data.DataServiceConstants"
include_class "java.io.StringWriter"
include_class "java.io.StringReader"
include_class "org.cagrid.cql.utilities.CQL1toCQL2Converter"
include_class "org.cagrid.cql.utilities.CQL2SerializationUtil"
include_class "org.cagrid.cql.utilities.iterator.CQL2QueryResultsIterator"

module CqlQuery
  include_package "gov.nih.nci.cagrid.cqlquery"
end

module Cql2Results
  include_package "org.cagrid.cql2.results"
end

class DataServiceActions
  def getClient(service, cred)
    begin
      serviceEndpoint = EndpointReferenceType.new(Types::URI.new(service.to_java_string))     
      if(serviceEndpoint.getAddress.getScheme.eql?("http"))
        return DataServiceClient.new(serviceEndpoint)
      else
        return DataServiceClient.new(serviceEndpoint, cred)
      end
    rescue
      puts "DataServiceActions:getClient:Error: " + $!    
    end
  end
  
#  def getCQL2Client(service, cred)
#    begin
#      
#    end
#  end
  
  def runQuery(client, query)
    begin
      #execute the query
      results = client.query(query)
      iter = CQLQueryResultsIterator.new(results, true)
      
      resultsXML = String.new
      while (iter.hasNext)
        singleResult = iter.next()
        resultsXML << singleResult
      end
      
      return resultsXML
    rescue
      puts "DataServiceActions:runQuery:Error: " + $!
    end
  end
  
  def runCQL2Query(client, query)
    begin
      Cql2Results::CQLAttributeResult
      puts "Running Query"
      results = client.executeQuery(query)
      puts "Return with Results"
      
      sw = StringWriter.new
      CQL2SerializationUtil.serializeCql2QueryResults(results, sw)
      array = sw.toString.split("\n")
      
      temp = Array.new
      array.each {|elem| 
        temp << elem.strip
      }
      sw = temp.join
      
      #      iter = CQL2QueryResultsIterator.new(results, true)
      #      resultsXML = String.new
      #      while (iter.hasNext)
      #        singleResult = iter.next()
      #        resultsXML << singleResult
      #      end
    rescue org.apache.axis.AxisFault
      puts "DataServiceActions:runCQL2Query:Error: " + $!
      return "org.apache.axis.AxisFault"
    rescue
      puts "DataServiceActions:runCQL2Query:Error: " + $!
    end
    
    return sw
  end
   
  def constructQuery(client, dbQuery)
    begin
      puts "Constructing Query"
      query = CqlQuery::CQLQuery.new
      target = CqlQuery::Object.new()
      target.setName(dbQuery.object)
      query.setTarget(target)
      
      # Set Modifiers if they exist
      queryModifier = CqlQuery::QueryModifier.new
      modifier = dbQuery.modifier
      if modifier.eql?("count")
        queryModifier.setCountOnly(true)
        query.setQueryModifier(queryModifier)
        
      elsif modifier.eql?("distinct_attribute")
        queryModifier.setDistinctAttribute(dbQuery.term.to_java_string)
        query.setQueryModifier(queryModifier)
        
      elsif modifier.eql?("selected_attributes")   
        queryModifier.setAttributeNames(dbQuery.term.split(',').to_java(:string))
        query.setQueryModifier(queryModifier)
      elsif modifier.eql?("association")
      # Associations are set
        associationList = dbQuery.term.split(',')
        roleName = associationList.at(0)
        attributeName = associationList.at(1)
        objectName = Association.find_by_roleName(roleName).objectName
        value = dbQuery.value
        predicate = Predicate.find_by_id(dbQuery.predicate_id).name
      
      # Build Attribute  
        attribute = CqlQuery::Attribute.new(attributeName.to_java_string, CqlQuery::Predicate.fromString(predicate.to_java_string), value.to_java_string)
      # Build association
        association = CqlQuery::Association.new(roleName)
        association.setName(objectName)
        association.setAttribute(attribute)
        target.setAssociation(association)
      end
      return query
    rescue
      puts "DataServiceActions:ConstructQuery:Error: " + $!
    end
  end
  
  def constructXmlQuery(client, xml, version)
    reader = StringReader.new(xml.to_java_string)
    puts version.class
    puts version
    if version
      puts "Creating CQL1 Query"    
      query = Utils.deserializeObject(reader, CqlQuery::CQLQuery.java_class)
    else
      puts "Creating CQL2 Query"
      query = CQL2SerializationUtil.deserializeCql2Query(reader)
    end
    
    return query
  end
  
  def getCQLQueryXML(query)
    begin
      writer = StringWriter.new
      Utils.serializeObject(query, DataServiceConstants::CQL_QUERY_QNAME, writer);
      return writer.getBuffer().toString()
    rescue
      puts "DataServiceActions:getCQLQueryXML:Error " + $!
    end
  end
  
  def getCQL2QueryXML(domainModel, query)
    converter = CQL1toCQL2Converter.new(domainModel)
    cql2Query = converter.convertToCql2Query(query)
    
    return CQL2SerializationUtil.serializeCql2Query(cql2Query)
  end

end
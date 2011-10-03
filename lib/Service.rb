class Service
  attr_accessor :address, :name, :description
  
  def ==(service)
    if self.address.eql?(service.address)
      if self.name.eql?(service.name)
        if self.description.eql?(service.description)
          return true
        end
      end
    end
  end
end
namespace :populate do
  require "GridClient.rb"
  
  task :all => [:AuthServiceURL, :AdminRoleID, :Predicates] do
    puts "All rake tasks performed"
  end
  
  desc "Add Authentication URLS"
  task :AuthServiceURL => :environment do
    client = GridClientClass.new
    idps = client.getAuthServiceURL
    count = 1
      idps.each { |idp| 
        AuthServiceUrl.create(:id => count, :url => idp.getAuthenticationServiceURL, :name => idp.getDisplayName)
        count += 1
      }
      puts "Authentication URLs added successfully"
  end
  
    task :Admin => :environment do
    admin = User.new
    admin.username = "admin"
    admin.cred = "not null"
    admin.firstname = "Site"
    admin.lastname = "Administrator"
    admin.password = "not_actual_password" #password must be present but is set in User:authAdmin
    if admin.save
      puts "Admin account saved successful"
    else
      puts "Admin account unsuccessful save"
    end
  end
  
  task :Role => :environment do
    addRole("Admin", "Site Administrator")
    addRole("User", "Normal User")
  end
  
  task :AdminRoleID => [:Role, :Admin] do
    role = Role.find_by_name("Admin")
    role.user_ids = role.user_ids << User.find_by_username("admin").id
    if role.save
      puts "Admin role assigned successful"
    else
      puts "Admin role unsuccessfully assigned"
    end
  end
  
  task :Predicates => :environment do
    array = Array.new
    array << "EQUAL_TO"
    array << "GREATER_THAN"
    array << "GREATER_THAN_EQUAL_TO"
    array << "IS_NOT_NULL"
    array << "IS_NULL"
    array << "LESS_THAN"
    array << "LESS_THAN_EQUAL_TO"
    array << "LIKE"
    array << "NOT_EQUAL_TO"
    
    array.each do |element|
      predicate = Predicate.new
      predicate.name = element
      unless Predicate.find_by_name(element)
        if predicate.save
          puts predicate.name + " predicate save successful"
        else
          puts predicate.name + " predicate unsuccessful save"
        end
      end
    end
  end

 def addRole(name, description)
    role = Role.new
    role.name = name
    role.description = description
    if role.save
      puts name + " role save successful"
    else
      puts name + " role unsuccessful save"
    end
  end
  
end
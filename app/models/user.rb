class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  attr_accessible :firstname, :lastname, :username, :password, :password_confirmation
  
  attr_accessor :password
  attr_accessor :password_confirmation
  attr_accessor :url_id
  before_save :downcase_username
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :username
  validates_presence_of :firstname
  validates_presence_of :lastname
  validates_uniqueness_of :username
  
  def downcase_username
    self.username.downcase!
  end
  
  def self.authUser(username, password, url_id)
    user = find_by_username(username)
    userCred = Array.new
    if user
      client = GridClientClass.new
      cred = client.loginUser(username, password, url_id[0])      
      if !cred.nil?
        puts cred.getIdentity
        
        userCred << user
        userCred << cred
        puts "User Model"
        puts userCred
        userCred
      end
    else
      userCred
    end
  end
  
  def self.authAdmin(password)
    if password == "CITIH"
      return find_by_username("admin")
    end
  end
  
end

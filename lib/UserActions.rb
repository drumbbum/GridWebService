require "java"

include_class "org.cagrid.gaards.authentication.BasicAuthentication"
include_class "org.cagrid.gaards.authentication.client.AuthenticationClient"
include_class "org.cagrid.gaards.dorian.federation.CertificateLifetime"
include_class "org.cagrid.gaards.dorian.federation.TrustedIdentityProvider"
include_class "org.cagrid.gaards.dorian.client.GridUserClient"
include_class "org.globus.gsi.GlobusCredential"


class UserActions
  @serviceUrl
  def initialize(dorianUrl)
    @serviceUrl = dorianUrl
  end
  
  def getAuthServiceURL
    begin
      gridClient = GridUserClient.new(@serviceUrl)
      puts "Service Url"
      puts @serviceUrl
      idps = gridClient.getTrustedIdentityProviders()
      return idps
    end
  end
  
  def loginUser(username, password, url)
    puts "UserActions: loginUser"
    begin
      # Authenticate to the IdP (DorianIdP) using credential
      puts url
      authClient = AuthenticationClient.new(url.to_java_string)
      puts "AuthenticationClient called."
      begin
        saml = authClient.authenticate(BasicAuthentication.new(password.to_java_string, username.to_java_string))
      rescue 
        puts "Athentication Error: " + $!
        return
      end

      lifetimeHours = 12
      lifetime = CertificateLifetime.new
      lifetime.setHours(lifetimeHours)
      
      #Request PKI/Grid Credential
      dorian = GridUserClient.new(@serviceUrl)
      credential = dorian.requestUserCertificate(saml, lifetime)
    rescue
      raise RuntimeError,"Error: " + $!
    end
   
    return credential   
  end
end
class UsersController < ApplicationController
  before_filter :authorize, :except => [:new, :create, :index]
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.url_id = params[:auth_service_url]
    begin
      #Get Grid Credentials
      if (!@user.username.nil? and !@user.password.nil? and @user.password == @user.password_confirmation)
        client = GridClientClass.new
        cred = client.loginUser(@user.username, @user.password, @user.url_id[0])
        if !cred.nil?
          @user.cred = cred.getIdentity
        end
      end
      if @user.save
        redirect_to log_in_path, :notice => "Signed up!"
      else
        render "new"
      end
    rescue
      redirect_to sign_up_path, :notice => "Dorian Username or Password is incorrect"
      puts "Error: " + $!
    end
  end
  
  def update
    params[:user] ||= User.find(params[:id])
    params[:user][:role_ids] ||= []
    @user = User.find(params[:id])
    puts "Update Attibutes"
    @user.role_ids = params[:user][:role_ids] 
    respond_to do |format|
      if @user.save
        format.html { redirect_to(role_assign_path, :notice => 'Role was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end

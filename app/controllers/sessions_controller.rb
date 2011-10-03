class SessionsController < ApplicationController
  def new
  end
  
  def create
    if params[:username] == "admin"
      user = User.authAdmin(params[:password])
      cred = nil
    else
      username = String.new(params[:username])
      userCred = User.authUser(username.downcase, params[:password], params[:auth_service_url])
      if !userCred.nil?
        user = userCred.at(0)      
        if userCred.length > 1
          cred = userCred.at(1)
        end
      end
    end
    if user
      session[:user_id] = user.id
      session[:globus] = cred
      redirect_to roles_path, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid username or password"
      render "new"
    end
    
  end
  
  def destroy
    session[:user_id] = nil
    session[:globus] = nil
    redirect_to log_in_path, :notice => "Logged out!"
  end
  
end

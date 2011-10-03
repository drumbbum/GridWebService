class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  
  helper_method :current_user?
  helper_method :admin?
  helper_method :authorize
  helper_method :logged_in
  helper_method :getGlobusCred
  
  # Global Variable holding available services
  $DATA_SERVICES
  $ANALYTICAL_SERVICES
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def current_user?
    !session[:user_id].nil?
  end
  
  def logged_in
    unless current_user?
      flash[:error] = "Please Log In First"
      redirect_to log_in_path
    end
  end
  
  def admin?
    current_user.role_ids.include?(Role.find_by_name("Admin").id)
  end
  
  def authorize
    unless admin?
      flash[:error] = "Unauthorized Access"
      redirect_to root_url
      false
    end
  end
  
  def getGlobusCred
    return session[:globus]
  end
  
end

class ApplicationController < ActionController::Base
  def current_user
	User.find(session[:user]) if session[:user]
  end
  def require_login
    redirect_to '/' if session[:user] == nil
  end
  def require_correct_user
    begin User.find(params[:id])
    	user = User.find(params[:id])
    	redirect_to "/" if current_user != user
    rescue
    	redirect_to "/"
    end
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end

class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create, :login]
  before_action :require_correct_user, only: [:index]
  def index
  	@user = User.find(params[:id])
  	friended_by = @user.friended_by
  	@additional_friends = friended_by - @user.friends
  end
  def new
  end
  def create
  	user = User.create(user_params)
	flash[:error] = []
	messages = user.errors.full_messages
	if params[:user][:confirm_password] != params[:user][:password]
  		messages.push("Confirm password does not match password")
  	end
  	flash[:error] = messages
	if messages.any?
		redirect_to '/'
	else
		user.password_digest
		session[:user] = user.id
		redirect_to '/professional_profile/' + user.id.to_s
	end
  end
  def login
  	user = User.find_by_email(login_params[:email].downcase)
  	flash[:errors] = []
  	messages = []
  	if user == nil
  		messages << "Entered email not in database"
  	else
  		verifyPassword = user.authenticate(login_params[:password])
  		unless verifyPassword
  			messages << "Incorrect Password"
  		end
  	end
  	if messages.any?
  		flash[:errors] = messages
  		return redirect_to '/'
  	else
  		session[:user] = user.id
  		return redirect_to '/professional_profile/' + user.id.to_s
  	end
  end
  def accept
  	Friendship.create(user_id: params[:id], friend_id: session[:user])
  	Invite.where(:user_id => params[:id], :friend_id => session[:user]).delete_all
  	return redirect_to '/professional_profile/' + session[:user].to_s
  end
  def ignore
  	Invite.where(:user_id => params[:id], :friend_id => session[:user]).delete_all
  	return redirect_to '/professional_profile/' + session[:user].to_s
  end
  def show
  	@user = User.find(params[:id])
  	@self = User.find(session[:user])
  end
  def deleteFriendship
  	Friendship.where(:user_id => params[:id], :friend_id => session[:user]).delete_all
  	Friendship.where(:user_id => session[:user], :friend_id => params[:id]).delete_all
  	return redirect_to '/professional_profile/' + session[:user].to_s
  end
  def connect
  	Invite.create(user_id: session[:user], friend_id: params[:id])
  	redirect_to '/users'
  end
  def all
  	allUsers = User.all
  	user = User.find(session[:user])
  	friended_by = user.friended_by
  	invited_by = user.invited_by
  	@self = user
  	@leftOverFriends = allUsers - user.friends - friended_by - invited_by - user.friends_invited - Array(user)
  end
  def logout
  	session[:user] = nil
  	redirect_to '/'
  end
  def user_params
	params.require(:user).permit(:name, :email, :description, :password)
  end
  def login_params
    params.require(:user).permit(:email, :password)
  end
end

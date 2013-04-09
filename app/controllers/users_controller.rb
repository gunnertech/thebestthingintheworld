class UsersController < ApplicationController
  before_filter :authenticate_user!
  
  skip_load_and_authorize_resource only: [:oauth]
  
  def oauth
    @oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], oauth_user_url("me"))
    if params[:client_id].present? || params[:code].present?
      current_user.facebook_access_token = @oauth.get_access_token(params[:code])
      current_user.save!
      
      redirect_to user_path("me"), notice: "Connected to Facebook!"
    else
      redirect_to @oauth.url_for_oauth_code(:permissions => "publish_stream,email,user_likes,publish_actions")
    end
  end

  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end
  
  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user], :as => :admin)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end
    
  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
    end
  end
  
  protected
  
  def set_user_id
    redirect_to new_user_session_path and return false if !signed_in? && params[:id] == 'me'
    
    params[:id] = current_user.id if params[:id] == 'me'
  end
  
end
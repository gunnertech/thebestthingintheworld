class UsersController < ApplicationController
  # before_filter :authenticate_user!
  
  skip_load_and_authorize_resource only: [:oauth, :login_with_facebook]
  skip_before_filter :set_user_id, only: [:oauth]
  
  def oauth
    @oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], oauth_user_url("me"))
    if params[:client_id].present? || params[:code].present?
      @user = current_user || User.new
      @user.facebook_access_token = @oauth.get_access_token(params[:code])
      
      if @user.new_record?
        @graph = Koala::Facebook::API.new(@user.facebook_access_token)
        profile = @graph.get_object("me")
        
        if user = User.where{ (facebook_id == my{profile["id"]}) | (email == my{profile["email"]}) | (facebook_access_token == my{@user.facebook_access_token}) }.first
          user.facebook_access_token = @user.facebook_access_token
          @user = user
        end
        
        @user.name = profile["name"]
        @user.email = profile["email"]
        @user.password = @user.facebook_access_token
        @user.facebook_id = profile["id"]
      elsif !@user.facebook_id
        @graph = Koala::Facebook::API.new(@user.facebook_access_token)
        @user.facebook_id = profile["id"]
      end
      
      @user.save!
      
      sign_in @user if !signed_in?
      
      redirect_to user_path("me"), notice: "Connected to Facebook!"
    else
      redirect_to @oauth.url_for_oauth_code(:permissions => "publish_stream,email,user_likes,publish_actions")
    end
  end
  
  def login_with_facebook
    url = "https://graph.facebook.com/oauth/access_token?client_id=#{ENV['FACEBOOK_APP_ID']}&client_secret=#{ENV['FACEBOOK_APP_SECRET']}&grant_type=fb_exchange_token&fb_exchange_token=#{params[:facebook_access_token]}"
    response = HTTParty.post(url)
    raise response.body.split('&').first.gsub(/access_token=/,"")
    @user = User.where{ facebook_access_token == my{params[:facebook_access_token]} }.first
    sign_in @user if @user
    render json: @user
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
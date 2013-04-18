class UsersController < ApplicationController
  # before_filter :authenticate_user!
  
  skip_load_and_authorize_resource only: [:oauth, :twitter_oauth]
  skip_before_filter :set_user_id, only: [:oauth, :twitter_oauth]
  
  def oauth
    @oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], oauth_user_url("me"))
    if params[:client_id].present? || params[:code].present?
      facebook_session = @oauth.try(:get_user_info_from_cookies, cookies) || {}
      @user = current_user || User.new
      @user.facebook_access_token = facebook_session["access_token"] || @oauth.get_access_token(params[:code])
      
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
        profile = @graph.get_object("me")
        @user.facebook_id = profile["id"]
      end
      
      @user.save!
      
      sign_in @user if !signed_in?
      
      redirect_to user_path("me"), notice: "Connected to Facebook!"
    else
      redirect_to @oauth.url_for_oauth_code(:permissions => "publish_stream,email,user_likes,publish_actions")
    end
  end
  
  def twitter_oauth
    @consumer = OAuth::Consumer.new(ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET'],
    { :site => "https://api.twitter.com",
      :request_token_path => '/oauth/request_token',
      :access_token_path => '/oauth/access_token',
      :authorize_path => '/oauth/authorize',
      :scheme => :header
    })
    
    if params[:oauth_verifier].present? && params[:oauth_token].present?
      token = @consumer.get_access_token(session[:request_token],oauth_verifier: params[:oauth_verifier])
      @user = current_user || User.new
      @user.twitter_access_token = token.token
      @user.twitter_access_secret = token.secret
      
      if @user.new_record?
        client = Twitter::Client.new(
          :oauth_token => @user.twitter_access_token,
          :oauth_token_secret => @user.twitter_access_secret
        )
      
        if user = User.where{ (twitter_id == my{client.user[:id]}) | (twitter_access_token == my{@user.twitter_access_token}) }.first
          @user = user
          @user.twitter_access_token = token.token
          @user.twitter_access_secret = token.secret
        end
      
        @user.twitter_id = client.user[:id]
        @user.name = client.user[:screen_name]
        @user.password = @user.twitter_access_token
        @user.email = "#{@user.name}@fake-from-twitter.com"
      end
      
      @user.save!
      
      sign_in @user if !signed_in?
      
      redirect_to user_path("me"), notice: "Connected to Twitter!"
    else
      @request_token = @consumer.get_request_token(:oauth_callback => "http://#{ENV['HOST']}/users/me/twitter_oauth")
      session[:request_token] = @request_token
      redirect_to @request_token.authorize_url
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
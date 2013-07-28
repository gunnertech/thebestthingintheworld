class ApplicationController < ActionController::Base
  layout Proc.new { |controller| controller.request.xhr? ? false : 'application' }
  load_and_authorize_resource except: :index, :unless => :devise_controller?
  protect_from_forgery
  
  before_filter :reconnect_with_facebook
  
  prepend_before_filter :set_user_id

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end
  
  protected
  
  def authorize_parent
    authorize! :read, (parent) if parent?
  end
  
  def set_user_id
    if !devise_controller?
      redirect_to new_user_session_path and return false if !signed_in? && params[:user_id] == 'me'
      params[:user_id] = current_user.id if params[:user_id] == 'me'
    end
  end
  
  
  def reconnect_with_facebook
    if current_user && current_user.facebook_access_token && current_user.token_expired?

    # session[:return_to] = request.env["REQUEST_URI"] unless request.env["REQUEST_URI"] == facebook_request_path
      redirect_to(oauth_user_url("me")) and return false
    end
  end
  

end

class ApplicationController < ActionController::Base
  layout Proc.new { |controller| controller.request.xhr? ? false : 'application' }
  load_and_authorize_resource except: :index, :unless => :devise_controller?
  protect_from_forgery
  
  prepend_before_filter :set_user_id

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  
  protected
  
  def authorize_parent
    authorize! :read, (parent) if parent?
  end
  
  def set_user_id
    redirect_to new_user_session_path and return false if !signed_in? && params[:user_id] == 'me'
    
    params[:user_id] = current_user.id if params[:user_id] == 'me'
  end
  

end

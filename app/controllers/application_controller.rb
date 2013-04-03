class ApplicationController < ActionController::Base
  load_and_authorize_resource except: :index, :unless => :devise_controller?
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  
  def authorize_parent
    authorize! :read, (parent) if parent?
  end

end

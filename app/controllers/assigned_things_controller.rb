class AssignedThingsController < InheritedResources::Base
  belongs_to :user
  prepend_before_filter :set_user_id
  before_filter :set_page, only: [:index]
  
  custom_actions resource: :move_up
  
  skip_load_and_authorize_resource only: [:move_up,:index]
  
  
  
  def move_up
    authorize! :move_up, resource
    resource.move_higher
    flash[:notice] = "You moved that thing up! Good for you!"
    redirect_to params[:return_to].present? ? params[:return_to] : user_assigned_things_comparision_url("me",page: params[:page])
  end
  
  def create
    create!{ assigned_things_comparision_url }
  end
  
  def update
    update!{ assigned_things_comparision_url(page: (AssignedThing.count - resource.position).to_s) }
  end
  
  protected
  
  def per_page
    params[:view] == 'compare' ? 1 : 25
  end
  
  def collection
    return @assigned_things if @assigned_things

    
    @assigned_things = end_of_association_chain.accessible_by(current_ability).paginate(page: (params[:page].to_i == 0 ? "1" : params[:page]), :per_page => per_page)
    
    
    @assigned_things = @assigned_things.reorder{ position.desc } if params[:view] == 'compare'
    
    @assigned_things
  end
  
  def set_page
    params[:page] = params[:page].present? ? params[:page] : "1"
  end
  
  def set_user_id
    redirect_to new_user_session_path and return false if !signed_in? && params[:user_id] == 'me'
    
    params[:user_id] = current_user.id if params[:user_id] == 'me'
  end
end

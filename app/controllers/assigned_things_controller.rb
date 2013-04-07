class AssignedThingsController < InheritedResources::Base
  belongs_to :user
  before_filter [:set_page], only: [:index]
  
  custom_actions resource: :move_up
  
  skip_load_and_authorize_resource only: [:move_up,:index]
  
  
  
  def move_up
    authorize! :move_up, resource
    resource.comparision = AssignedThing.find_by_id(params[:compared_to]) if params[:compared_to].present?
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
  
  def index
    @comparison_collection = parent.assigned_things.where{ position == my{ collection.last.position - 1} } if params[:view] == 'compare'
    index!
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
end

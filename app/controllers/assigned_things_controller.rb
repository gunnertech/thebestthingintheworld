class AssignedThingsController < InheritedResources::Base
  belongs_to :user
  before_filter [:set_page], only: [:index]
  
  custom_actions resource: :move_up
  
  respond_to :json, only: [:move_up]
  
  skip_load_and_authorize_resource only: [:move_up,:index]
  
  def move_up
    authorize! :move_up, resource
    resource.comparision = AssignedThing.find_by_id(params[:compared_to]) if params[:compared_to].present?
    current_position = resource.position
    if resource.comparision && resource.comparision.position + 1 != resource.position
      resource.insert_at(resource.comparision.position)
    elsif params[:position].present?
      resource.insert_at(params[:position].to_i)
    else
      resource.move_higher
    end
    
    flash[:notice] = "You moved that thing up! Good for you!"
    respond_to do |format|
      format.html { redirect_to(params[:return_to].present? ? params[:return_to] : user_assigned_things_comparision_url("me",first_thing_id: resource.thing_id, second_thing_id: resource.higher_item.thing_id)) }
      format.json { render json: resource }
    end
    
  end
  
  def create
    create!{ assigned_things_comparision_url }
  end
  
  def update
    update! do |success,failure|
      success.html { redirect_to(params[:return_to].present? ? params[:return_to] : resource_url)}
      failure.html { redirect_to(resource.thing) }
    end
  end
  
  def index
    if params[:view] == 'compare'
      if params[:second_thing_id].blank?
        next_position = (collection.first.try(:position) || 0) - 1
        @comparison_collection = parent.assigned_things.where{ position == my{ next_position } }
      else
        @comparison_collection = parent.assigned_things.joins{ thing }.where{ thing.id == my{ params[:second_thing_id]} }
      end
    end
    @random_thing_1 = Thing.where{ id >= my{rand(Thing.count)} }.reorder{ id.asc }.first
    @random_thing_2 = Thing.where{ id >= my{rand(Thing.count)} }.reorder{ id.asc }.first
    
    index!
  end
  
  protected
  
  def per_page
    params[:view] == 'compare' && params[:second_thing_id].blank? ? 1 : 100
  end
  
  def collection
    return @assigned_things if @assigned_things
    
    @assigned_things = end_of_association_chain.accessible_by(current_ability)
    
    @assigned_things = @assigned_things.paginate(page: (params[:page].to_i == 0 ? "1" : params[:page]), :per_page => per_page) unless params[:view] == 'compare'
    
    @assigned_things = @assigned_things.joins{ thing }.where{ (thing.id == my{params[:first_thing_id]}) | (thing.id == my{params[:second_thing_id]}) } if params[:first_thing_id].present? && params[:second_thing_id].present?
    
    @assigned_things = @assigned_things.reorder{ position.desc }.limit(3) if params[:view] == 'compare'
    
    @assigned_things
  end
  
  def set_page
    params[:page] = params[:page].present? ? params[:page] : "1"
  end
end

class ThingsController < InheritedResources::Base
  skip_load_and_authorize_resource only: [:index]
  
  before_filter :set_page, only: [:index]
  
  def create
    create!{ user_assigned_things_comparision_url("me") }
  end
  
  def update
    update!{ user_assigned_things_comparision_url("me",page: (Thing.count - resource.position).to_s) }
  end
  
  protected
  
  def per_page
    params[:view] == 'compare' ? 1 : 25
  end
  
  def collection
    return @things if @things
    
    @things = end_of_association_chain.accessible_by(current_ability).paginate(page: (params[:page].to_i == 0 ? "1" : params[:page]), :per_page => per_page)
    
    @things
  end
  
  def set_page
    params[:page] = params[:page].present? ? params[:page] : "1"
  end
  
end

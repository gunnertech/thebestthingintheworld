class ThingsController < InheritedResources::Base
  skip_load_and_authorize_resource only: [:index]
  
  belongs_to :user, optional: true
  
  before_filter :set_page, only: [:index]
  before_filter :set_suggested_images, only: [:edit,:new,:create]
  before_filter :set_comparison_thing, only: [:show]
  
  def create
    #create!(notice: "Thanks for the new Thing! We're busy spreading it throughout the interwebs so it may take a few minutes for it to show up."){ user_assigned_things_comparision_url("me") }
    create!(notice: "Your thing has been queued for creation. It will be available shortly.") { user_assigned_things_comparision_url("me") }
  end
  
  def update
    update!(notice: "Thanks for the update. Bare with us while we process the changes. It may take a few minutes to spread throughout the entire application."){ user_assigned_things_comparision_url("me",page: (Thing.count - resource.position).to_s) }
  end
  
  protected
  
  def set_suggested_images
    @image_urls = Thing.suggested_images(resource.name) if resource.name
  end
  
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
  
  def set_comparison_thing
    @comparison_thing = Thing.joins{ assigned_things }.where{ assigned_things.id == my{params[:comparison_thing_id]} }.limit(1).first if params[:comparison_thing_id].present?
    @user = User.find(params[:user_id]) if params[:user_id].present?
  end
  
end

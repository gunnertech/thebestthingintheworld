class ThingsController < InheritedResources::Base
  custom_actions resource: :move_up
  
  skip_load_and_authorize_resource only: [:move_up,:index]
  
  def move_up
    authorize! :move_up, resource
    resource.move_higher
    redirect_to things_comparision_url(page: params[:page])
  end
  
  protected
  
  def per_page
    params[:view] == 'compare' ? 2 : 25
  end
  
  def collection
    return @things if @things
    
    @things = end_of_association_chain.accessible_by(current_ability).paginate(page: params[:page], :per_page => per_page)
    
    #@things = @things.limit(2) if params[:view] == 'compare'
    
    @things
  end
  
end

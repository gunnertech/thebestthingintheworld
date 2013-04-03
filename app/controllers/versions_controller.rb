class VersionsController < InheritedResources::Base
  
  protected
  
  def per_page
    params[:view] == 'compare' ? 2 : 25
  end
  
  def collection
    return @versions if @versions
    
    @versions = end_of_association_chain.accessible_by(current_ability).reorder{ created_at.desc }.paginate(page: params[:page], :per_page => per_page)
    
    @versions
  end
  
end

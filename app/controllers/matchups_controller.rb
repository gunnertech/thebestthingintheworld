class MatchupsController < InheritedResources::Base
  
  def update
    update! { matchups_url }
  end
  
  protected
  def collection
    return @matchups if @matchups
    
    @matchups = end_of_association_chain.accessible_by(current_ability).paginate(page: (params[:page].to_i == 0 ? "1" : params[:page]))
    
    @matchups
  end
end

class AssignedThing < ActiveRecord::Base
  belongs_to :thing, dependent: :destroy
  belongs_to :user, dependent: :destroy
  
  attr_accessible :thing, :user
  attr_accessor :comparision
  
  acts_as_list scope: :user
  
  after_update :update_things_average_position
  after_save :queue_for_facebook, if: Proc.new{ |assigned_thing| assigned_thing.user.facebook_access_token }
  
  validates :thing_id, uniqueness: {scope: :user_id}
  
  default_scope order{ position.asc }
  
  def to_s
    thing.to_s
  end
  
  def update_things_average_position
    thing.average_position = thing.assigned_things.group{ id }.select{ [avg(position)] }.first.try(:avg)
    thing.save!
  end
  handle_asynchronously :update_things_average_position
  
  def queue_for_facebook
    post_to_facebook(
      user.facebook_access_token,
      Rails.application.routes.url_helpers.thing_url(thing, comparison_thing_id: comparision.try(:id), host: ENV['HOST'])
    )
  end
  
  def post_to_facebook(token,url)
    graph = Koala::Facebook::API.new(token)
    graph.put_connections("me", "tbtitworld:like", thing: url)
  end
  handle_asynchronously :post_to_facebook
  
end

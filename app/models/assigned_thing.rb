class AssignedThing < ActiveRecord::Base
  belongs_to :thing, dependent: :destroy
  belongs_to :user, dependent: :destroy
  
  attr_accessible :thing, :user, :new_position, :comparision_id, :email_addresses
  attr_accessor :comparision, :new_position, :comparision_id, :email_addresses
  
  acts_as_list scope: :user
  
  after_update :update_things_average_position
  after_save :queue_for_facebook, if: Proc.new{ |assigned_thing| assigned_thing.user.facebook_access_token }
  
  before_validation :move_position, if: Proc.new{ |assigned_thing| assigned_thing.new_position.present? }
  before_validation :share_via_email, if: Proc.new{ |assigned_thing| assigned_thing.email_addresses.present? }
  
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
  
  def move_position
    if new_position.to_i > Thing.count
      errors.add(:new_position, "can't be greater than #{Thing.count}")
    elsif new_position.to_i < 1
      errors.add(:new_position, "can't be less than than 1")
    else
      insert_at(new_position.to_i)
    end
  end  
  
  def share_via_email
    thing_2 = AssignedThing.where{ id == my{comparision_id} }.first.try(:thing)
    ShareMailer.matchup_email(user,thing,thing_2,email_addresses).deliver
  end
end

class AssignedThing < ActiveRecord::Base
  belongs_to :thing, dependent: :destroy
  belongs_to :user, dependent: :destroy
  
  attr_accessible :thing, :user
  
  acts_as_list scope: :user
  
  after_update :update_things_average_position
  
  validates :thing_id, uniqueness: {scope: :user_id}
  
  default_scope order{ position.asc }
  
  def update_things_average_position
    thing.average_position = thing.assigned_things.group{ id }.select{ [avg(position)] }.first.try(:avg)
    thing.save!
  end
  handle_asynchronously :update_things_average_position
  
end

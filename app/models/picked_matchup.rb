class PickedMatchup < ActiveRecord::Base
  belongs_to :matchup
  belongs_to :thing
  belongs_to :user
  
  attr_accessible :matchup_id, :thing_id, :user_id, :thing, :matchup
  
  validates :matchup_id, presence: true
  validates :thing_id, presence: true
  validates :user_id, presence: true
end

class Matchup < ActiveRecord::Base
  belongs_to :thing_1, class_name: "Thing"
  belongs_to :thing_2, class_name: "Thing"
  
  has_many :picked_matchups, dependent: :destroy
  
  attr_accessible :featured, :thing_1_id, :thing_2_id
  
  validates :thing_1_id, presence: true, uniqueness: {scope: :thing_2_id}
  validates :thing_2_id, presence: true, uniqueness: {scope: :thing_1_id}
  validate :matchup_does_not_exist
  
  default_scope order{ [featured.desc, updated_at.desc] }
  
  after_save :update_things
  
  def wins_for(t)
    picked_matchups.where{ thing_id == my{t.id} }.count
  end
  
  def update_things
    thing_1.save!
    thing_2.save!
  end
  
  def matchup_does_not_exist
    t1_id = thing_1_id
    t2_id = thing_2_id
    matchups_for_thing_1 = Matchup.where{ (thing_1_id == my{t1_id}) | (thing_2_id == my{t1_id}) }
    return false if matchups_for_thing_1.where{ thing_1_id == my{t2_id}}.count > 0 || matchups_for_thing_1.where{ thing_2_id == my{t2_id}}.count > 0
    matchups_for_thing_2 = Matchup.where{ (thing_1_id == my{t2_id}) | (thing_2_id == my{t2_id}) }
    return false if matchups_for_thing_2.where{ thing_1_id == my{t1_id}}.count > 0 || matchups_for_thing_2.where{ thing_2_id == my{t1_id}}.count > 0
    
    return true
  end
  
  class << self
    def set_up_for(t1,t2)
      return false if t1.nil? || t2.nil? || t1 == t2
      if self.where{ (thing_1_id == my{t1.id}) & (thing_2_id == my{t2.id}) }.count == 0 && self.where{ (thing_1_id == my{t2.id}) & (thing_2_id == my{t1.id}) }.count
        self.create!(thing_1_id: t1.id, thing_2_id: t2.id)
      else
        self.where{ (thing_1_id == my{t1.id}) & (thing_2_id == my{t2.id}) }.first || self.where{ (thing_1_id == my{t2.id}) & (thing_2_id == my{t1.id}) }.first
      end
    end
  end
end

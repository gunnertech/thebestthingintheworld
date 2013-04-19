class Matchup < ActiveRecord::Base
  belongs_to :thing_1, class_name: "Thing"
  belongs_to :thing_2, class_name: "Thing"
  
  has_many :picked_matchups, dependent: :destroy
  
  attr_accessible :featured, :thing_1_id, :thing_2_id
  
  validates :thing_1_id, presence: true, uniqueness: {scope: :thing_2_id}
  validates :thing_2_id, presence: true, uniqueness: {scope: :thing_1_id}
  
  default_scope order{ [featured.desc, updated_at.desc] }
  
  def wins_for(t)
    picked_matchups.where{ thing_id == my{t.id} }.count
  end
  
  class << self
    def set_up_for(t1,t2)
      return false if t1.nil? || t2.nil?
      if self.where{ (thing_1_id == my{t1.id}) & (thing_2_id == my{t2.id}) }.count == 0 && self.where{ (thing_1_id == my{t2.id}) & (thing_2_id == my{t1.id}) }.count
        self.create!(thing_1_id: t1.id, thing_2_id: t2.id)
      else
        self.where{ (thing_1_id == my{t1.id}) & (thing_2_id == my{t2.id}) }.first || self.where{ (thing_1_id == my{t2.id}) & (thing_2_id == my{t1.id}) }.first
      end
    end
  end
end

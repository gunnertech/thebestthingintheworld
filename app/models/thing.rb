class Thing < ActiveRecord::Base
  attr_accessible :name
  acts_as_list
  has_paper_trail
  
  validates :name, presence: true, uniqueness: true
  
  default_scope order{ position.asc }
end

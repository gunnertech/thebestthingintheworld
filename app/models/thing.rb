class Thing < ActiveRecord::Base
  attr_accessible :name
  acts_as_list
  
  validates :name, presence: true, uniqueness: true
  
  default_scope order{ position.asc }
end

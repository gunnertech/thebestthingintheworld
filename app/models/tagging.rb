class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :thing
  # attr_accessible :title, :body
end

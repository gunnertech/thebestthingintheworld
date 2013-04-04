class Thing < ActiveRecord::Base
  attr_accessible :name, :image
  acts_as_list
  has_paper_trail
  has_attached_file :image, 
                    :styles => { :small => "196x196#", :medium => "600x400#", :large => "1200x800#"},
                    :storage => :s3,
                    :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
                    :path => ':attachment/:id/:style.:extension',
                    :default_style => :large,
                    :s3_headers => { 'Expires' => 1.year.from_now.httpdate },
                    :s3_host_alias => Settings.paperclip.s3_host_alias,
                    :default_url => "/assets/images/:style/missing.png",
                    :url => Settings.paperclip.url
  
  validates :name, presence: true, uniqueness: true
  validates_attachment_size :image, :less_than => 5.megabytes
  
  default_scope order{ position.asc }
end

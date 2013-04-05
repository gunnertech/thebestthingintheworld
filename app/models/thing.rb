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
  
  has_many :assigned_things
  has_many :users, through: :assigned_things
  
  validates :name, presence: true, uniqueness: true
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_presence :image
  
  default_scope order{ average_position.asc }
  
  after_create :add_assigned_things
  
  def to_s
    name
  end
  
  def add_assigned_things
    User.find_in_batches do |group|
      sleep(1)
      group.each do |user|
        AssignedThing.create(user: user, thing: self)
      end
    end
  end
  handle_asynchronously :add_assigned_things
end

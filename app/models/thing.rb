class Thing < ActiveRecord::Base
  attr_accessible :name, :image, :tag_list, :image_url
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
  has_many :taggings
  has_many :tags, through: :taggings
  
  validates :name, presence: true, uniqueness: true
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_presence :image, if: Proc.new{ |thing| thing.image_url.blank? }
  
  default_scope order{ average_position.asc }
  
  scope :tagged_with, lambda { |tag| joins{ tags }.where{ tags.name == my{tag} } }
  
  after_create :add_assigned_things
  after_create :send_notifications
  
  after_save :download_image, if: Proc.new{ |thing| thing.image_url.present? && thing.image_url_changed? }
  
  
  before_image_post_process do |thing|
    if !thing.image_processing? && thing.image_changed?
      thing.image_processing = true
      false # halts processing
    end
  end
  
  after_save do
    if image_processing? && image_changed?
      delay.regenerate_styles!
    end
  end
  
  def regenerate_styles!
    self.update_column(:image_processing, false)
    self.image.reprocess!
  end
  
  def to_s
    name
  end
  
  def download_image
    self.image = URI.parse(image_url) rescue nil
    self.image_url = nil
    save
  end
  handle_asynchronously :download_image
    
  def creator
    User.find(versions.first.whodunnit)
  end
  
  def tag_list
    tags.map(&:name).join(', ')
  end
  
  def tag_list=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip).first_or_create!
    end
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
  
  def send_notifications
    ThingMailer.notification_email(self).deliver
  end
  handle_asynchronously :send_notifications
  
  def image_changed?
    image_file_size_changed? ||
    image_file_name_changed? ||
    image_content_type_changed? ||
    image_url_changed?
  end
  
  class << self
    def suggested_images(term='coffee')
      url = "https://www.google.com/search?q=#{URI.escape(term)}&hl=en&source=lnms&tbm=isch&sa=X&ei=BE9gUdG3HYmc9QSzmYH4Dg&ved=0CAcQ_AUoAQ&biw=1270&bih=735"
      a = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
      image_urls = []

      a.get(url) do |page|
        page.links_with(class: "rg_l").each do |link|
          matches = link.href.to_s.match(/imgurl=([^&]+)/)
          image_urls.push matches[1]
        end
      end
      
      image_urls
    end
  end
end

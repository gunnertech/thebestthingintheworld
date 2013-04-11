class Thing < ActiveRecord::Base
  attr_accessible :name, :image, :tag_list, :image_url
  acts_as_list
  has_paper_trail
  has_attached_file :image, 
                    :styles => { :small => "196x196^", :medium => "600x338^", :large => "1024x576^"},
                    :convert_options => { :small => "-gravity North -crop 196x196+0+0 -quality 75 -strip", :medium => "-gravity North -crop 600x338+0+0 -quality 75 -strip", :large => "-gravity North -crop 1024x576+0+0 -quality 75 -strip" },
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
  after_create :queue_for_facebook, if: Proc.new{ |thing| thing.creator }
  
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
  
  def to_param
    "#{id}-#{to_s.parameterize}"
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
    if image.exists?
      ThingMailer.notification_email(self).deliver
    else
      send_notifications
    end
  end
  handle_asynchronously :send_notifications
  
  def image_changed?
    image_file_size_changed? ||
    image_file_name_changed? ||
    image_content_type_changed? ||
    image_url_changed?
  end
  
  def queue_for_facebook
    if image.exists?
      post_to_facebook(
        creator.facebook_access_token,
        Rails.application.routes.url_helpers.thing_url(self, host: ENV['HOST'])
      )
    else
      self.delay.queue_for_facebook
    end
  end
  
  
  def post_to_facebook(token,url)
    graph = Koala::Facebook::API.new(token)
    graph.put_connections("me", "tbtitworld:add", thing: url)
  end
  handle_asynchronously :post_to_facebook
  
  class << self
    def suggested_images(term='coffee')
      url = "https://www.google.com/search?q=#{URI.escape(term)}&hl=en&biw=1389&bih=800&tbm=isch&source=lnt&tbs=isz:ex,iszw:1200,iszh:800&sa=X&ei=6fVlUfalEpHK9gS8hoHgBA&ved=0CCwQpwUoBQ#q=#{URI.escape(term)}&hl=en&tbs=iszw:1200,iszh:800,isz:lt,islt:xga&tbm=isch&source=lnt&sa=X&ei=BvZlUcDnG4fu9ATjoIGIDw&ved=0CCIQpwU&bav=on.2,or.r_cp.r_qf.&bvm=bv.45107431,d.eWU&fp=469a30c85ca8a294&biw=1389&bih=734"
      #url = "https://www.google.com/search?q=#{URI.escape(term)}&hl=en&source=lnms&tbm=isch&sa=X&ei=BE9gUdG3HYmc9QSzmYH4Dg&ved=0CAcQ_AUoAQ&biw=1270&bih=735"
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

class AssignedThing < ActiveRecord::Base
  belongs_to :thing, dependent: :destroy
  belongs_to :user, dependent: :destroy
  
  attr_accessible :thing, :user, :new_position, :comparision_id, :email_addresses, :phone_number
  attr_accessor :comparision, :new_position, :comparision_id, :email_addresses, :phone_number
  
  acts_as_list scope: :user
  
  after_update :update_things_average_position
  after_save :queue_for_facebook, if: Proc.new{ |assigned_thing| assigned_thing.user.facebook_access_token && assigned_thing.position_changed? }
  after_save :queue_for_twitter, if: Proc.new{ |assigned_thing| assigned_thing.user.twitter_access_token && assigned_thing.position_changed? }
  
  before_validation :move_position, if: Proc.new{ |assigned_thing| assigned_thing.new_position.present? }
  before_validation :share_via_email, if: Proc.new{ |assigned_thing| assigned_thing.email_addresses.present? }
  before_validation :share_via_sms, if: Proc.new{ |assigned_thing| assigned_thing.phone_number.present? }
  
  after_save :create_picked_matchup, if: Proc.new{ |assigned_thing| assigned_thing.comparision.present? }
  
  validates :thing_id, uniqueness: {scope: :user_id}
  
  default_scope order{ position.asc }
  
  def to_s
    thing.to_s
  end
  
  def create_picked_matchup
    matchup = Matchup.set_up_for(thing,comparision.thing)
    user.picked_matchups.create!(matchup: matchup, thing: thing)
  end
  
  def update_things_average_position
    thing.average_position = thing.assigned_things.group{ id }.select{ [avg(position)] }.first.try(:avg)
    thing.save!
  end
  handle_asynchronously :update_things_average_position
  
  def queue_for_facebook
    post_to_facebook(
      user.facebook_access_token,
      Rails.application.routes.url_helpers.thing_url(thing, comparison_thing_id: comparision.try(:thing).try(:id), host: ENV['HOST'])
    )
  end
  
  def queue_for_twitter
    post_to_twitter(
      comparision,
      user.twitter_access_token,
      user.twitter_access_secret,
      Rails.application.routes.url_helpers.thing_url(thing, comparison_thing_id: comparision.try(:thing).try(:id), host: ENV['HOST'])
    )
  end
  
  def post_to_twitter(c,token,secret,url)
    client = Twitter::Client.new(
      :oauth_token => token,
      :oauth_token_secret => secret
    )
    if c
      client.update("#{self.thing.to_s} is better than #{c.to_s} #{url}")
    else
      client.update("I moved up #{self.thing.to_s} #{url}")
    end
    
  end
  handle_asynchronously :post_to_twitter
  
  def post_to_facebook(token,url)
    graph = Koala::Facebook::API.new(token)
    graph.put_connections("me", "tbtitworld:like", thing: url) rescue nil
  end
  handle_asynchronously :post_to_facebook
  
  def move_position
    if new_position.to_i > Thing.count
      errors.add(:new_position, "can't be greater than #{Thing.count}")
    elsif new_position.to_i < 1
      errors.add(:new_position, "can't be less than than 1")
    else
      insert_at(new_position.to_i)
    end
  end  
  
  def share_via_email
    thing_2 = AssignedThing.where{ id == my{comparision_id} }.first.try(:thing)
    ShareMailer.matchup_email(user,thing,thing_2,email_addresses).deliver
  end
  handle_asynchronously :share_via_email
  
  def share_via_sms(mobile_number = nil, c_id = nil)
    if mobile_number.nil?
      self.delay.share_via_sms(phone_number,comparision_id)
    elsif ENV['BLOWERIO_URL']
      thing_2 = AssignedThing.where{ id == my{c_id} }.first.try(:thing)
      
      Bitly.use_api_version_3
      bitly = Bitly.new("gunnertech", "R_b75c09fa28aa15f9e53ccb9245a9acf6")
      url = "http://#{ENV['HOST']}/users/me/assigned_things/compare?first_thing_id=#{thing.try(:id)}&second_thing_id=#{thing_2.try(:id)}"
      u = bitly.shorten(url)
      
      body = "#{user.name} wants to know what you think is better: #{thing.to_s} or #{thing_2.to_s} - #{u.short_url}"
      
      useable_number = ActionController::Base.helpers.number_to_phone(mobile_number.gsub(/\D/,""))
      if useable_number.length == 12
        useable_number = "+1#{useable_number.gsub(/\D/,"")}"
      else
        useable_number = "+#{useable_number.gsub(/\D/,"")}"
      end
      
      blower_url = ENV['BLOWERIO_URL']
      blowerio = RestClient::Resource.new(blower_url)
      blowerio['/messages'].post :to => useable_number, :message => body
    end
  end
  handle_asynchronously :share_via_sms
end

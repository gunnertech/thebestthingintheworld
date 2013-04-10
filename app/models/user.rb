class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :disconnect_from_facebook, :send_new_thing_notification
  attr_accessor :disconnect_from_facebook
  
  has_many :assigned_things
  has_many :things, through: :assigned_things
  
  after_create :set_up_assigned_things
  before_validation :remove_facebook_token, if: Proc.new{ |user| user.disconnect_from_facebook.present? }
  
  def to_s
    name
  end
  
  def set_up_assigned_things
    Thing.find_in_batches do |group|
      sleep(1)
      group.each do |thing|
        at = AssignedThing.new(user: self, thing: thing)
        at.save
        at.set_list_position(thing.average_position.to_i)
      end
    end
  end
  handle_asynchronously :set_up_assigned_things
  
  def remove_facebook_token
    self.facebook_access_token = nil
  end
  
end

class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  
  has_many :assigned_things
  has_many :things, through: :assigned_things
  
  after_create :set_up_assigned_things
  
  def to_s
    name
  end
  
  def set_up_assigned_things
    Thing.find_in_batches do |group|
      sleep(1)
      group.each do |thing|
        at = AssignedThing.new(user: self, thing: thing)
        at.position = thing.average_position.to_i
        at.save
      end
    end
  end
  handle_asynchronously :set_up_assigned_things
  
end

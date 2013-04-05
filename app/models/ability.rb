class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    elsif !user.new_record?
      can [:move_up], AssignedThing, user_id: user.id
      can [:create], Thing
      can :manage, Thing do |thing|
        thing.creator == user
      end
    end
    can :read, :all
  end
end

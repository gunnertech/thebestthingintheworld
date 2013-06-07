class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    elsif !user.new_record?
      can [:move_up,:update], AssignedThing, user_id: user.id
      can [:create], Thing
      can :manage, Thing do |thing|
        thing.new_record? || thing.creator == user
      end
      can :read, Thing
    end
    can :read, :all
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assigned_thing do
    thing nil
    user nil
    position 1
  end
end

FactoryBot.define do
  factory :user do

  end
  factory :location do
    sequence(:name) { |i| "LocationName#{i}" }
  end

  factory :group do
    location
    sequence(:name) { |i| "GroupName#{i}" }
  end
end

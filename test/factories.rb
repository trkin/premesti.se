FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@email.com" }
  end
  factory :city do
    sequence(:name) { |i| "CityName#{i}" }
  end
  factory :location do
    sequence(:name) { |i| "LocationName#{i}" }
    city
  end

  factory :group do
    location
    sequence(:name) { |i| "GroupName#{i}" }
  end
end

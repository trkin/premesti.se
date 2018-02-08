FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@email.com" }
    password 'factory_password'
    confirmed_at { Time.current }
    factory :unconfirmed_user do
      confirmed_at nil
    end
    trait :admin do
      admin true
    end
  end
  factory :city do
    sequence(:name) { |i| "CityName#{i}" }
  end
  factory :location do
    sequence(:name) { |i| "LocationName#{i}" }
    sequence(:address) { |i| "LocationAddress#{i}" }
    city
  end
  factory :group do
    location
    sequence(:name) { |i| "GroupName#{i}" }
    sequence(:age) { |i| i }
  end
  factory :move do
    association :from_group, factory: :group
    user
  end
end

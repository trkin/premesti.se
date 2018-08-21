FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@email.com" }
    password { 'factory_password' }
    confirmed_at { Time.current }
    locale { I18n.default_locale }
    factory :unconfirmed_user do
      confirmed_at { nil }
    end
    trait :admin do
      admin { true }
    end
  end
  factory :city do
    sequence(:name) { |i| "CityName#{i}" }
  end
  factory :location do
    sequence(:name) { |i| "LocationName#{i}" }
    sequence(:address) { |i| "LocationAddress#{i}" }
    latitude { '1' }
    longitude { '1' }
    city
  end
  factory :group do
    location
    sequence(:name) { |i| "GroupName#{i}" }
    sequence(:age) { |i| (i % 7) + 1 }
  end
  factory :move do
    association :from_group, factory: :group
    user
  end
  factory :chat do
  end
  factory :message do
    sequence(:text) { |i| "Text#{i}" }
    chat
    user
  end
end

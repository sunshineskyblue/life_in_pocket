FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "test_password" }
    name { "test_user" }
    introduction { "test_user_introduction" }
  end
end

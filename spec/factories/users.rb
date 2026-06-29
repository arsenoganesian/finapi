FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    balance { 0 }
  end
end

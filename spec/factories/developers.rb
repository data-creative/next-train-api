FactoryGirl.define do
  factory :developer do
    sequence(:email){ |n| "tad.codey+#{n}@example.com" }
    password "MyPass123"
    confirmed_at Time.zone.now
  end
end

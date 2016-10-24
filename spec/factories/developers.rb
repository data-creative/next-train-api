FactoryGirl.define do
  factory :developer do
    email
    first_name "Tad"
    last_name "Codey"
    encrypted_password "MyPass123"
    confirmed_at Time.zone.now
  end
end

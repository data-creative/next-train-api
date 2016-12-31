FactoryGirl.define do
  factory :agency do
    schedule
    url "http://www.my-transit-agency.com/"
    abbrev "MTA"
    name "My Transit Agency"
    timezone "America/New_York"
    phone "1-123-456-7890"
    lang "en"
  end
end

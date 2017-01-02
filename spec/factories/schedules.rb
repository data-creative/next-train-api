FactoryGirl.define do
  factory :schedule do
    published_at { rand(4.years).seconds.ago }
    content_length 1
    source_url "http://www.my-transit-agency.com/google_transit.zip"

    factory :schedule_with_etag do
      etag "1abc-876543db34567"
    end
  end
end

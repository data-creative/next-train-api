FactoryGirl.define do
  factory :schedule do
    published_at { rand(4.years).seconds.ago }
    content_length 1
    source_url "http://www.my-transit-agency.com/google_transit.zip"
    active false

    factory :active_schedule do
      active true
    end

    #trait :inactive do
    #  active false
    #end

    #trait :with_etag do
    #  etag "1abc-876543db34567"
    #end

    #trait :with_associations do
    #  after(:create) do |schedule, evaluator|
    #    create :agency, schedule: schedule
    #    create :calendar, schedule: schedule
    #    create :calendar_date, schedule: schedule
#
    #    stop = create :stop, schedule: schedule
    #    route = create :route, schedule: schedule
#
    #    #TODO: 2.times do
    #      trip = create :trip, schedule: schedule, route: route
#
    #      #TODO: 3.times do
    #        create :stop_time, schedule: schedule, trip: trip, stop: stop
    #      #end
    #    #end
    #  end
    #end
  end
end

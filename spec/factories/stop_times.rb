FactoryGirl.define do
  factory :stop_time do
    schedule
    trip
    stop
    stop_sequence 23
    arrival_time "5:30:00"
    departure_time "5:30:00"
  end

  factory :described_stop_time do
    headsign "New Haven - Union"
    pickup_code 0
    dropoff_code 0
    distance 789
    code 0
  end

  #factory :post_midnight_stop_time do
  #  #TODO: handle some chronological shenanigans
  #end
end

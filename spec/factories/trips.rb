FactoryGirl.define do
  factory :trip do
    schedule
    guid "16hundred" #"1600" #NOTE: using "1600" triggers Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::NonCaseSwappableValueError
    route
    service_guid "WD"
    headsign "Eastbound"
  end

  factory :described_trip do
    short_name "My Trip"
    direction_code 0
    block_guid "DEF"
    shape_guid "XYZ"
    wheelchair_code 0
    bicycle_code 0
  end
end

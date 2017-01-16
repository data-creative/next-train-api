FactoryGirl.define do
  factory :calendar_date do
    schedule
    service_guid "D0"
    exception_date "2016-12-31"
    exception_code 2

    trait :addition do
      exception_code 1
    end
  end
end

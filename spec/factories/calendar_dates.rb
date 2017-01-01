FactoryGirl.define do
  factory :calendar_date do
    schedule
    service_id "D0"
    exception_date "2016-12-31"
    exception_code 2
  end
end

FactoryGirl.define do
  factory :calendar do
    schedule
    service_id "WD"
    monday true
    tuesday true
    wednesday true
    thursday true
    friday true
    saturday false
    sunday false
    start_date "20161105".to_date
    end_date "20170501".to_date
  end
end

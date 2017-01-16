FactoryGirl.define do
  factory :calendar do
    schedule
    service_guid "WD"
    monday true
    tuesday true
    wednesday true
    thursday true
    friday true
    saturday false
    sunday false
    start_date "20161105".to_date
    end_date "20170501".to_date

    trait :in_service do
      monday true
      tuesday true
      wednesday true
      thursday true
      friday true
      saturday true
      sunday true
    end

    trait :out_of_service do
      monday false
      tuesday false
      wednesday false
      thursday false
      friday false
      saturday false
      sunday false
    end
  end
end

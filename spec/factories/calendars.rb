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

    trait :all_days do
      monday true
      tuesday true
      wednesday true
      thursday true
      friday true
      saturday true
      sunday true
    end
=begin
    trait :no_days do
      monday false
      tuesday false
      wednesday false
      thursday false
      friday false
      saturday false
      sunday false
    end

    trait :weekdays do
      monday true
      tuesday true
      wednesday true
      thursday true
      friday true
      saturday false
      sunday false
    end

    trait :weekends do
      monday false
      tuesday false
      wednesday false
      thursday false
      friday false
      saturday true
      sunday true
    end
=end
  end
end

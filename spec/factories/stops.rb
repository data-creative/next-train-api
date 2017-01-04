FactoryGirl.define do
  factory :stop do
    schedule
    guid "NHV"
    name "New Haven Union Station"
    latitude "41.29771887088102"
    longitude "-72.92673110961914"

    factory :described_stop do
      zone_guid "1"
      url "http://www.shorelineeast.com/service_info/stations/nh_u.php"
    end

    factory :parented_stop do
      parent_guid { ["MOM","DAD"].shuffle }

      after(:create) do |recently_created_stop, evaluator|
        create(:stop, guid: recently_created_stop.parent_guid)
      end
    end
  end
end

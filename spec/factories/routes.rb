FactoryGirl.define do
  factory :route do
    schedule
    guid "MR"
    short_name "MR"
    long_name "My Route"
    code 2
  end

  factory :descriptive_route do
    agency_guid "MTA"
    description "MR trains operate between Inwood-207 St, Manhattan and Far Rockaway-Mott Avenue, Queens at all times. Also from about 6AM until about midnight, additional A trains operate between Inwood-207 St and Lefferts Boulevard (trains typically alternate between Lefferts Blvd and Far Rockaway)."
    url "http://www.my-transit-agency.com/my-route"
    color "000000"
    text_color "00FFFF"
  end
end

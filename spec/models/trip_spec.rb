require 'rails_helper'

RSpec.describe Trip, "associations", type: :model do
  it { should belong_to(:schedule) }
  it { should belong_to(:route) }
  it { should belong_to(:calendar) }
  it { should have_many(:stop_times).dependent(:destroy) }

  describe "when having many stop times" do
    let(:schedule){ create(:schedule, :id => 123)}
    let(:trip){ create(:trip, :schedule_id => schedule.id) }
    let(:stop_time){ create(:stop_time, :schedule_id => schedule.id, :trip_guid => trip.guid)}

    let(:other_schedule){ create(:schedule, :id => 456)}
    let(:stop_time_from_another_schedule){ create(:stop_time, :schedule_id => other_schedule.id, :trip_guid => trip.guid)} # the point is here that both stop_times share the same trip, as if they are just different versions of the same record, but belonging to a different schedules

    it "should have only those belonging to the same schedule as it" do
      expect(trip.stop_times).to include(stop_time)
      expect(trip.stop_times).to_not include(stop_time_from_another_schedule)
    end
  end
end

RSpec.describe Trip, "validations", type: :model do
  it { should validate_presence_of(:schedule_id)}
  it { should validate_presence_of(:guid)}
  it { should validate_presence_of(:route_guid)}
  it { should validate_presence_of(:service_guid)}

  it { should validate_inclusion_of(:direction_code).in_array([0,1]).allow_nil }
  it { should validate_inclusion_of(:wheelchair_code).in_array([0,1,2]).allow_nil }
  it { should validate_inclusion_of(:bicycle_code).in_array([0,1,2]).allow_nil }

  subject { create(:trip) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:guid).scoped_to(:schedule_id) }
end

RSpec.describe Trip, ".in_service_on" do
  let(:service_start_date){ "2017-01-01".to_date }
  let(:service_end_date){ "2017-12-31".to_date }
  let(:service_date){ rand(service_start_date..service_end_date) }

  let(:schedule){ create(:schedule, :active) }

  let(:calendar){ create(:calendar, :all_days, :schedule_id => schedule.id, :start_date => service_start_date, :end_date => service_end_date )}
  let(:trip){ create(:trip, :schedule_id => schedule.id, :calendar => calendar) }

  let(:empty_calendar){ create(:calendar, :no_days, :schedule_id => schedule.id, :start_date => service_start_date, :end_date => service_end_date )}
  let(:out_of_service_trip){ create(:trip, :schedule_id => schedule.id, :calendar => empty_calendar) }

  it "should include all trips belonging to in-service calendars" do
    trip
    expect(described_class.in_service_on(service_date.to_s)).to_not be_empty
  end

  it "should not include any trips belonging to out-of-service calendars" do
    out_of_service_trip
    expect(described_class.in_service_on(service_date.to_s)).to be_empty
  end
end

RSpec.describe Trip, ".traveling_in_direction" do
  let(:earlier_stop_sequence){ 5 }
  let(:later_stop_sequence){ earlier_stop_sequence + 3 }

  let(:schedule){ create(:schedule)}
  let(:trip){ create(:trip, :schedule_id => schedule.id) }
  let(:origin){ create(:stop, :schedule_id => schedule.id, :guid => "ST")}
  let(:destination){ create(:stop, :schedule_id => schedule.id, :guid => "BRN")}

  let(:origin_stop_time){ create(:stop_time, :schedule_id => schedule.id, :trip_guid => trip.guid, :stop_guid => origin.guid, :stop_sequence => earlier_stop_sequence)}
  let(:destination_stop_time){ create(:stop_time, :schedule_id => schedule.id, :trip_guid => trip.guid, :stop_guid => destination.guid, :stop_sequence => later_stop_sequence)}

  describe "stop inclusion conditions" do
    it "should include trips which stop at both the origin station and the destination station" do
      origin_stop_time
      destination_stop_time
      expect(described_class.traveling_in_direction(:from => "ST", :to => "BRN")).to_not be_empty
    end

    it "should not include trips which stop at the origin but not the destination station" do
      origin_stop_time
      expect(described_class.traveling_in_direction(:from => "ST", :to => "BRN")).to be_empty
    end

    it "should not include trips which stop at the destination but not the origin station" do
      destination_stop_time
      expect(described_class.traveling_in_direction(:from => "ST", :to => "BRN")).to be_empty
    end
  end

  describe "stop sequence conditions" do
    let(:reverse_origin_stop_time){ create(:stop_time, :schedule_id => schedule.id, :trip_guid => trip.guid, :stop_guid => origin.guid, :stop_sequence => later_stop_sequence)}
    let(:reverse_destination_stop_time){ create(:stop_time, :schedule_id => schedule.id, :trip_guid => trip.guid, :stop_guid => destination.guid, :stop_sequence => earlier_stop_sequence)}

    it "should include trips traveling in the proper direction (based on stop sequence)" do
      origin_stop_time
      destination_stop_time
      expect(described_class.traveling_in_direction(:from => "ST", :to => "BRN")).to_not be_empty
    end

    it "should not include trips traveling in the improper direction (based on stop sequence)" do
      reverse_origin_stop_time
      reverse_destination_stop_time
      expect(described_class.traveling_in_direction(:from => "ST", :to => "BRN")).to be_empty
    end
  end
end

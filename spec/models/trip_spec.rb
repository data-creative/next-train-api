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

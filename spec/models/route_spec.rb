require 'rails_helper'

RSpec.describe Route, "associations", type: :model do
  it { should belong_to(:schedule) }
  it { should have_many(:trips).dependent(:destroy) }

  describe "when having many trips" do
    let(:schedule){ create(:schedule, :id => 123) }
    let(:route){ create(:route, :schedule_id => schedule.id) }
    let(:trip){ create(:trip, :schedule_id => schedule.id, :route_guid => route.guid) }

    let(:other_schedule){ create(:schedule, :id => 456) }
    let(:trip_from_another_schedule){ create(:trip, :schedule_id => other_schedule.id, :route_guid => route.guid)} # the point is here that both trips share the same route, as if they are just different versions of the same record, but belonging to a different schedules

    it "should have only those belonging to the same schedule as it" do
      expect(route.trips).to include(trip)
      expect(route.trips).to_not include(trip_from_another_schedule)
    end
  end
end

RSpec.describe Route, "validations", type: :model do
  it { should validate_presence_of(:schedule_id)}
  it { should validate_presence_of(:guid) }
  it { should validate_presence_of(:short_name) }
  it { should validate_presence_of(:long_name) }
  it { should validate_presence_of(:code) }

  it { should validate_inclusion_of(:code).in_array((0..7).to_a) }

  subject { create(:route) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:guid).scoped_to(:schedule_id) }
end

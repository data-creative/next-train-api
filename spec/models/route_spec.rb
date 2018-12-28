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
  it { should validate_presence_of(:code) }

  it { should validate_inclusion_of(:code).in_array((0..7).to_a) }

  subject { create(:route) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:guid).scoped_to(:schedule_id) }

  describe "#validate_short_or_long_name" do
    let(:nil_names) { create(:route, long_name: nil, short_name: nil) }
    let(:blank_names) { create(:route, long_name: "", short_name: "") }
    let(:blank_short_name) { create(:route, long_name: "My long name", short_name: "") }
    let(:nil_short_name) { create(:route, long_name: "My long name", short_name: nil) }
    let(:blank_long_name) { create(:route, long_name: "", short_name: "My short name") }
    let(:nil_long_name) { create(:route, long_name: nil, short_name: "My short name") }
    let(:both_names) { create(:route, long_name: "My long name", short_name: "My short name") }

    # @see https://developers.google.com/transit/gtfs/reference/#routestxt
    it "validates presence of either short or long name" do
      #expect(nil_names.valid?).to be false
      expect { nil_names }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name Short name and Long name can't both be blank")
      #expect(blank_names.valid?).to be false
      expect { blank_names }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name Short name and Long name can't both be blank")

      expect(blank_short_name.valid?).to be true
      expect(nil_short_name.valid?).to be true
      expect(blank_long_name.valid?).to be true
      expect(nil_long_name.valid?).to be true
      expect(both_names.valid?).to be true
    end
  end
end

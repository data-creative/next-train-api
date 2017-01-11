require 'rails_helper'

RSpec.describe Stop, "associations", type: :model do
  it { should belong_to(:schedule) }
  it { should have_many(:stop_times).dependent(:destroy) }

  describe "when having many stop times" do
    let(:schedule){ create(:schedule, :id => 123)}
    let(:stop){ create(:stop, :schedule_id => schedule.id) }
    let(:stop_time){ create(:stop_time, :schedule_id => schedule.id, :stop_guid => stop.guid)}

    let(:other_schedule){ create(:schedule, :id => 456)}
    let(:stop_time_from_another_schedule){ create(:stop_time, :schedule_id => other_schedule.id, :stop_guid => stop.guid)} # the point is here that both stop_times share the same stop, as if they are just different versions of the same record, but belonging to a different schedules

    it "should have only those belonging to the same schedule as it" do
      expect(stop.stop_times).to include(stop_time)
      expect(stop.stop_times).to_not include(stop_time_from_another_schedule)
    end
  end
end

RSpec.describe Stop, "validations", type: :model do
  it { should validate_presence_of(:schedule_id)}
  it { should validate_presence_of(:guid)}
  it { should validate_presence_of(:name)}
  it { should validate_presence_of(:latitude)}
  it { should validate_presence_of(:longitude)}

  it { should validate_inclusion_of(:location_code).in_array([0,1]).allow_nil }
  it { should validate_inclusion_of(:wheelchair_code).in_array([0,1,2]).allow_nil }

  subject { create(:stop) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:guid).scoped_to(:schedule_id) }
end

RSpec.describe Stop, "#location_classification", type: :model do
  let(:stop){ create(:stop, :location_code => nil)}

  it "treats a blank location_code as code '0'" do
    expect(stop.location_classification[:name]).to eql("Stop")
  end
end

RSpec.describe Stop, "#wheelchair_boarding", type: :model do
  let!(:stop){ create(:stop, :wheelchair_code => nil)}
  let(:parented_stop){ create(:parented_stop, :wheelchair_code => nil)}

  it "treats a blank wheelchair_code as code '0'" do
    expect(stop.wheelchair_boarding).to eql("Indicates that there is no accessibility information for the stop.")
    expect(parented_stop.wheelchair_boarding).to eql("The stop will inherit its wheelchair_boarding value from the parent station, if specified in the parent.")
  end
end

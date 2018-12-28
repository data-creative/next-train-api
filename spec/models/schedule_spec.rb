require 'rails_helper'

RSpec.describe Schedule, "associations", type: :model do
  it { should have_many(:agencies).dependent(:destroy) }
  it { should have_many(:calendars).dependent(:destroy) }
  it { should have_many(:calendar_dates).dependent(:destroy) }
  it { should have_many(:routes).dependent(:destroy) }
  it { should have_many(:stops).dependent(:destroy) }
  it { should have_many(:trips).dependent(:destroy) }
  it { should have_many(:stop_times).dependent(:destroy) }
end

RSpec.describe Schedule, "validations", type: :model do
  it { should validate_presence_of(:source_url) }
  it { should validate_presence_of(:published_at) }

  # it { should validate_inclusion_of(:active).in_array([true, false]) } #> throws warning from shoulda-matchers

  subject { create(:schedule) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:published_at).scoped_to(:source_url) }

  describe "#at_most_one_active_schedule" do
    context "when activating a schedule without first deactivating others" do
      let!(:active_schedule){ create(:schedule, :active)}
      let(:schedule){ create(:schedule) }

      before(:each) do
        schedule.update(:active => true)
      end

      it "should throw an error" do
        expect(schedule.errors.full_messages).to include("Active can only describe a single schedule. please deactivate other schedule(s) before attempting to activate this one.")
      end
    end
  end
end

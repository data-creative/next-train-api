require 'rails_helper'

RSpec.describe Schedule, "associations", type: :model do
  it { should have_many(:agencies) }
  it { should have_many(:calendars) }
  it { should have_many(:calendar_dates) }
  it { should have_many(:routes) }
  it { should have_many(:stops) }
  it { should have_many(:trips) }
  it { should have_many(:stop_times) }
end

RSpec.describe Schedule, "validations", type: :model do
  it { should validate_presence_of(:source_url) }
  it { should validate_presence_of(:published_at) }

  subject { create(:schedule) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:published_at).scoped_to(:source_url) }
end

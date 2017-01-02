require 'rails_helper'

RSpec.describe Stop, "association", type: :model do
  it { should belong_to(:schedule) }
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

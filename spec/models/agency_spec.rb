require 'rails_helper'

RSpec.describe Agency, "associations", type: :model do
  it { should belong_to(:schedule) }
end

RSpec.describe Agency, "validations", type: :model do
  it { should validate_presence_of(:schedule_id)}
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:timezone) }

  subject { create(:agency) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:url).scoped_to(:schedule_id) }
end

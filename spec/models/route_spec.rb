require 'rails_helper'

RSpec.describe Route, "association", type: :model do
  it { should belong_to(:schedule) }
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

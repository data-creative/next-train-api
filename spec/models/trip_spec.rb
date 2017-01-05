require 'rails_helper'

RSpec.describe Trip, "association", type: :model do
  it { should belong_to(:schedule) }
  it { should belong_to(:route) }
  #it { should belong_to(:service) }
  it { should have_many(:stop_times).dependent(:destroy) }
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

require 'rails_helper'

RSpec.describe StopTime, "association", type: :model do
  it { should belong_to(:schedule) }
  it { should belong_to(:trip) }
  it { should belong_to(:stop) }
end

RSpec.describe StopTime, "validations", type: :model do
  it { should validate_presence_of(:schedule_id)}
  it { should validate_presence_of(:trip_guid)}
  it { should validate_presence_of(:stop_guid)}
  it { should validate_presence_of(:stop_sequence)}
  it { should validate_presence_of(:departure_time)}
  it { should validate_presence_of(:arrival_time)}

  it { should validate_inclusion_of(:pickup_code).in_array([0,1,2,3]).allow_nil }
  it { should validate_inclusion_of(:dropoff_code).in_array([0,1,2,3]).allow_nil }
  it { should validate_inclusion_of(:code).in_array([0,1]).allow_nil }

  subject { create(:stop_time) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:stop_guid).scoped_to(:schedule_id, :trip_guid) }
end

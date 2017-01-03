require 'rails_helper'

RSpec.describe Calendar, "associations", type: :model do
  it { should belong_to(:schedule) }
end

RSpec.describe Calendar, "validations", type: :model do
  it { should validate_presence_of(:schedule_id)}
  it { should validate_presence_of(:service_guid) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:end_date) }

  #it { should validate_inclusion_of(:monday).in_array([true, false]) } # triggers warning from shoulda-matchers about this not being "fully-possible to test"
  #it { should validate_inclusion_of(:tuesday).in_array([true, false]) } # triggers warning from shoulda-matchers about this not being "fully-possible to test"
  #it { should validate_inclusion_of(:wednesday).in_array([true, false]) } # triggers warning from shoulda-matchers about this not being "fully-possible to test"
  #it { should validate_inclusion_of(:thursday).in_array([true, false]) } # triggers warning from shoulda-matchers about this not being "fully-possible to test"
  #it { should validate_inclusion_of(:friday).in_array([true, false]) } # triggers warning from shoulda-matchers about this not being "fully-possible to test"
  #it { should validate_inclusion_of(:saturday).in_array([true, false]) } # triggers warning from shoulda-matchers about this not being "fully-possible to test"
  #it { should validate_inclusion_of(:sunday).in_array([true, false]) } # triggers warning from shoulda-matchers about this not being "fully-possible to test"

  subject { create(:calendar) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:service_guid).scoped_to(:schedule_id) }
end

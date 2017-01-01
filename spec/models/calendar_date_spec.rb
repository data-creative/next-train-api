require 'rails_helper'

RSpec.describe CalendarDate, "associations", type: :model do
  it { should belong_to(:schedule) }
end

RSpec.describe CalendarDate, "validations", type: :model do
  it { should validate_presence_of(:service_id) }
  it { should validate_presence_of(:exception_date) }
  it { should validate_presence_of(:exception_code) }

  it { should validate_inclusion_of(:exception_code).in_array([1, 2]) }

  subject { create(:calendar_date) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid. not sure if the expectations above this line are affected...
  it { should validate_uniqueness_of(:exception_date).scoped_to(:schedule_id, :service_id) }
  ### it { should validate_uniqueness_of(:exception_code).scoped_to(:schedule_id, :service_id, :exception_date) }
end
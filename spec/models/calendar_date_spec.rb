require 'rails_helper'

RSpec.describe CalendarDate, "associations", type: :model do
  it { should belong_to(:schedule) }
  it { should belong_to(:calendar) }
end

RSpec.describe CalendarDate, "validations", type: :model do
  it { should validate_presence_of(:schedule_id)}
  it { should validate_presence_of(:service_guid) }
  it { should validate_presence_of(:exception_date) }
  it { should validate_presence_of(:exception_code) }
  it { should validate_inclusion_of(:exception_code).in_array([1, 2]) }

  describe "instance-dependant validations" do
    let(:calendar){ create(:calendar) }
    subject { create(:calendar_date, :schedule_id => calendar.schedule_id, :service_guid => calendar.service_guid) } # line below needs this to avoid Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid.

    it { should validate_uniqueness_of(:exception_date).scoped_to(:schedule_id, :service_guid) }
  end
end

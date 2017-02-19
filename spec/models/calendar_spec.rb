require 'rails_helper'

RSpec.describe Calendar, "associations", type: :model do
  it { should belong_to(:schedule) }
  it { should have_many(:calendar_dates).dependent(:destroy) }
  it { should have_many(:trips).dependent(:destroy) }

  describe "when having many calendar dates" do
    let(:schedule){ create(:schedule, :id => 123) }
    let(:calendar){ create(:calendar, :schedule_id => schedule.id) }
    let(:calendar_date){ create(:calendar_date, :schedule_id => schedule.id, :service_guid => calendar.service_guid) }

    let(:other_schedule){ create(:schedule, :id => 456) }
    let(:calendar_date_from_another_schedule){ create(:calendar_date, :schedule_id => other_schedule.id, :service_guid => calendar.service_guid)} # the point is here that both calendar_dates share the same calendar, as if they are just different versions of the same record, but belonging to a different schedules

    it "should have only those belonging to the same schedule as it" do
      expect(calendar.calendar_dates).to include(calendar_date)
      expect(calendar.calendar_dates).to_not include(calendar_date_from_another_schedule)
    end
  end

  describe "when having many trips" do
    let(:schedule){ create(:schedule, :id => 123) }
    let(:calendar){ create(:calendar, :schedule_id => schedule.id) }
    let(:trip){ create(:trip, :schedule_id => schedule.id, :service_guid => calendar.service_guid) }

    let(:other_schedule){ create(:schedule, :id => 456) }
    let(:trip_from_another_schedule){ create(:trip, :schedule_id => other_schedule.id, :service_guid => calendar.service_guid)} # the point is here that both trips share the same calendar, as if they are just different versions of the same record, but belonging to a different schedules

    it "should have only those belonging to the same schedule as it" do
      expect(calendar.trips).to include(trip)
      expect(calendar.trips).to_not include(trip_from_another_schedule)
    end
  end
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

RSpec.describe Calendar, ".in_service_on", type: :model do
  # todo: differentiate between calendars belonging to active vs inactive schedules

  let(:schedule){ create(:active_schedule) }
  let(:service_start_date){ "2017-01-01".to_date }
  let(:service_end_date){ "2017-12-31".to_date }
  let(:calendar){ create(:calendar, :all_days, :schedule_id => schedule.id, :start_date => service_start_date, :end_date => service_end_date )}
  let(:empty_calendar){ create(:calendar, :no_days, :schedule_id => schedule.id, :start_date => service_start_date, :end_date => service_end_date )}

  let(:service_date){ rand(service_start_date..service_end_date) }
  let(:pre_service_date){ service_start_date - 10.days }
  let(:post_service_date){ service_end_date + 10.days }

  it "should include calendars starting before and ending after the specified date" do
    calendar
    expect(described_class.in_service_on(service_date.to_s)).to_not be_empty
  end

  it "should be inclusive, returning calendars starting or ending on the specified date" do
    calendar
    expect(described_class.in_service_on(service_start_date.to_s)).to_not be_empty
    expect(described_class.in_service_on(service_end_date.to_s)).to_not be_empty
  end #NOTE: GTFS specification says the end_date "is included in the service interval."

  it "should not include calendars starting after or ending before the specified date" do
    calendar
    expect(described_class.in_service_on(pre_service_date.to_s)).to be_empty
    expect(described_class.in_service_on(post_service_date.to_s)).to be_empty
  end

  context "when there is an addition exception" do
    context "when the calendar was originally in-service on that date" do
      let!(:additional_date){ create(:calendar_date, :addition, :exception_date => service_date,
                                                                :service_guid => calendar.service_guid,
                                                                :schedule_id => calendar.schedule_id)}

      it "should still include the calendar as being in-service on that date" do
        additional_date
        expect(described_class.in_service_on(service_date.to_s)).to_not be_empty
      end
    end

    context "when the calendar was not originally in-service on that date" do
      let!(:additional_date){ create(:calendar_date, :addition, :exception_date => service_date,
                                                                :service_guid => empty_calendar.service_guid,
                                                                :schedule_id => empty_calendar.schedule_id)}

      it "should now include the calendar as being in-service on that date" do
        additional_date
        expect(described_class.in_service_on(service_date.to_s)).to_not be_empty
      end
    end
  end

  context "when there is a removal exception" do
    context "when the calendar was originally in-service on that date" do
      let!(:removed_date){ create(:calendar_date, :removal, :exception_date => service_date,
                                                                :service_guid => calendar.service_guid,
                                                                :schedule_id => calendar.schedule_id)}

      it "should no longer include the calendar as being in-service on that date" do
        removed_date
        expect(described_class.in_service_on(service_date.to_s)).to be_empty
      end
    end

    context "when the calendar was not originally in-service on that date" do
      let!(:removed_date){ create(:calendar_date, :removal, :exception_date => service_date,
                                                                :service_guid => empty_calendar.service_guid,
                                                                :schedule_id => empty_calendar.schedule_id)}

      it "should still not include the calendar as being in-service on that date" do
        removed_date
        expect(described_class.in_service_on(service_date.to_s)).to be_empty
      end
    end
  end
end

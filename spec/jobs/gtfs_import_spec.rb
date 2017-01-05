require 'rails_helper'
require_relative '../support/gtfs_import_helpers'

RSpec.describe GtfsImport, "#forced?", type: :job do
  let(:source_url){ "http://www.my-site.com/gtfs-feed.zip"}
  let(:import){ GtfsImport.new(:source_url => source_url)}
  let(:forced_import){ GtfsImport.new(:source_url => source_url, :forced => true)}
  let(:nonforced_import){ GtfsImport.new(:source_url => source_url, :forced => false)}

  it "should properly indicate whether or not the :forced option was invoked" do
    expect(import.forced?).to eql(false)
    expect(forced_import.forced?).to eql(true)
    expect(nonforced_import.forced?).to eql(false)
  end
end

RSpec.describe GtfsImport, "#perform", type: :job do
  let(:source_url){ "http://www.my-site.com/gtfs-feed.zip"}
  let(:import){ described_class.new(:source_url => source_url) }
  let(:imported_schedule){ Schedule.where(:source_url => source_url, :published_at => last_modified_at, :etag => etag, :content_length => content_length).first }

  context "when unsuccessful due to errors ocurring after metadata extraction" do
    let!(:pre_import_active_schedule){ create(:active_schedule) }

    before(:each) do
      stub_download_zip(source_url)
      allow(import).to receive(:transform_and_load).and_raise("OOPS SOME VALIDATION ERROR OR SOMETHING")
    end

    it "should not de-activate the active schedule" do
      begin
        import.perform
      rescue
      ensure
        expect(pre_import_active_schedule.active?).to eql(true)
      end
    end

    it "should persist but not activate the imported schedule" do
      begin
        import.perform
      rescue
      ensure
        expect(imported_schedule).to_not be_blank
        expect(imported_schedule.active?).to eql(false)
      end
    end
  end

  context "when successful" do
    let(:imported_stop){ Stop.find_by_guid("NHV") }
    let(:imported_consolidated_stop_times){ StopTime.where(:trip_guid => "1640", :stop_guid => "NHV")} # there were originally two different stop times, the first with arrival and departure at 17:44:00, and the second with arrival and departure at 17:48:00

    before(:each) do
      stub_download_zip(source_url)
      import.perform
    end

    it "should persist transit schedule metadata" do
      expect(imported_schedule).to_not be_blank
    end

    it "should persist transit schedule data" do
      expect(Agency.count).to eql(1)
      expect(Calendar.count).to eql(6)
      expect(CalendarDate.count).to eql(8)
      expect(Route.count).to eql(1)
      expect(Stop.count).to eql(17)
      expect(StopTime.count).to eql(120) # there are two intentionally sequential duplicates, else should expect 122
      expect(Trip.count).to eql(14)
    end

    it "should persist stop latitude and longitude to 8 decimal places" do
      expect(imported_stop.latitude.to_f).to eql(41.29771887)
      expect(imported_stop.longitude.to_f).to eql(-72.92673111)
    end

    it "should consolidate duplicative sequential stop times, using the earliest arrival and latest departure" do
      expect(imported_consolidated_stop_times.count).to eql(1)
      expect(imported_consolidated_stop_times.first.arrival_time).to eql("17:44:00")
      expect(imported_consolidated_stop_times.first.departure_time).to eql("17:48:00")
    end

    it "should mark the imported schedule as active" do
      expect(imported_schedule.active?).to eql(true)
    end
  end

  context "when forced" do
    let!(:pre_import_hosted_active_schedule){ create(:active_schedule, {
      :published_at => headers["last-modified"].first.to_datetime,
      :content_length => headers["content-length"].first.to_i,
      :etag => headers["etag"].first.tr('"','')
    }) }
    let(:forced_import){ GtfsImport.new(:source_url => source_url, :forced => true)}

    before(:each) do
      stub_download_zip(source_url)
    end

    it "should proceed regardless of whether or not the hosted schedule matches the active schedule" do
      expect(forced_import).to receive(:transform_and_load)
      expect(forced_import).to receive(:activate)
      forced_import.perform
    end
  end
end

RSpec.describe GtfsImport, "#parse_numeric", type: :job do
  it "should convert a numeric string to an integer" do
    expect(described_class.new.send(:parse_numeric, "0")).to eql(0)
  end

  it "should convert a blank value to nil, not zero" do
    expect(described_class.new.send(:parse_numeric, "")).to eql(nil)
  end
end

RSpec.describe GtfsImport, "#parse_decimal", type: :job do
  it "should retain 8 decimal places" do
    expect(described_class.new.send(:parse_decimal, " -72.92673110961914")).to eql(-72.92673111)
  end
end

require 'rails_helper'
require_relative '../support/gtfs_import_helpers'

RSpec.describe GtfsImport, "#perform", type: :job do
  let(:source_url){ "http://www.my-site.com/gtfs-feed.zip"}
  let(:schedule){ Schedule.last }
  let(:my_station){ Stop.find_by_guid("NHV") }

  before(:each) do
    stub_download_zip(source_url)
    described_class.new(:source_url => source_url).perform
  end

  it "should persist transit schedule metadata" do
    expect(schedule.published_at.to_datetime).to eql(headers["last-modified"].first.to_datetime)
    expect(schedule.content_length).to eql(headers["content-length"].first.to_i)
    expect(schedule.etag).to eql(headers["etag"].first.tr('"',''))
  end

  it "should persist transit schedule data" do
    expect(Agency.count).to eql(1)
    expect(Calendar.count).to eql(6)
    expect(CalendarDate.count).to eql(34)
    expect(Route.count).to eql(1)
    expect(Stop.count).to eql(17)
    expect(StopTime.count).to eql(515) # expect(StopTime.count).to eql(520)
    expect(Trip.count).to eql(71)
  end

  pending "should persist transit schedule data derivations" #expect(Train.count).to eql(100)

  it "should persist stop latitude and longitude to 8 decimal places" do
    expect(my_station.latitude.to_f).to eql(41.29771887)
    expect(my_station.longitude.to_f).to eql(-72.92673111)
  end
end

#RSpec.describe GtfsImport, "#perform", type: :job do
#  let(:schedule){ Schedule.last }
#
#  before(:each) do
#    allow(described_class).to receive(:open){ |&block| block.call(zip_file) }
#  end
#
#  context "during performance" do
#    it "should not yet mark the schedule as 'active'" do
#      binding.pry
#      expect(schedule.active?).to eql(false)
#    end
#  end
#
#  context "upon successful completion" do
#    it "should mark the schedule as 'active'" do
#      binding.pry
#      #expect(schedule.active?).to eql(true)
#    end
#  end
#end

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

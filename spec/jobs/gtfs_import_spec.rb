require 'rails_helper'

RSpec.describe GtfsImport, "#perform", type: :job do
  let(:source_url){ "http://www.my-site.com/gtfs-feed.zip"}
  let(:headers){
    {
      "date"=>["Fri, 30 Dec 2016 23:50:31 GMT"],
      "server"=>["Apache/2.4.10 (FreeBSD) OpenSSL/1.0.1j PHP/5.4.35"],
      "last-modified"=>["Tue, 23 Nov 2016 14:58:36 GMT"],
      "etag"=>["\"1ac9-542737db15840\""],
      "accept-ranges"=>["bytes"],
      "content-length"=>["9999"],
      "connection"=>["close"],
      "content-type"=>["application/zip"]
    }
  }
  let!(:zip_file){ Zip::File.open("./spec/data/mock_google_transit.zip") }
  let(:latest_schedule){ Schedule.latest }
  let(:my_station){ Stop.find_by_guid("NHV") }

  before(:each) do
    stub_request(:get, source_url).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
       to_return(:status => 200, :body => "xyz", :headers => headers)

    allow(Zip::File).to receive(:open){ |&block| block.call(zip_file) }

    described_class.new(:source_url => source_url).perform
  end

  it "should persist transit schedule metadata" do
    expect(latest_schedule.published_at.to_datetime).to eql(headers["last-modified"].first.to_datetime)
    expect(latest_schedule.content_length).to eql(headers["content-length"].first.to_i)
    expect(latest_schedule.etag).to eql(headers["etag"].first.tr('"',''))
  end

  it "should persist transit schedule data and derivations" do
    # data:
    expect(Agency.count).to eql(1)
    expect(Calendar.count).to eql(6)
    expect(CalendarDate.count).to eql(34)
    expect(Route.count).to eql(1)
    expect(Stop.count).to eql(17)
    expect(StopTime.count).to eql(515) # expect(StopTime.count).to eql(520)
    #expect(Trip.count).to eql(71)

    # derivations:
    #expect(Train.count).to eql(100)
  end

  it "should persist stop latitude and longitude to 8 decimal places" do
    expect(my_station.latitude.to_f).to eql(41.29771887)
    expect(my_station.longitude.to_f).to eql(-72.92673111)
  end

  pending "should designate the imported schedule as 'active'"
end

RSpec.describe GtfsImport, "#parse_numeric", type: :job do
  it "should convert a numeric string to an integer" do
    expect(described_class.new.parse_numeric("0")).to eql(0)
  end

  it "should convert a blank value to nil, not zero" do
    expect(described_class.new.parse_numeric("")).to eql(nil)
  end
end

RSpec.describe GtfsImport, "#parse_decimal", type: :job do
  it "should retain 8 decimal places" do
    expect(described_class.new.parse_decimal(" -72.92673110961914")).to eql(-72.92673111)
  end
end

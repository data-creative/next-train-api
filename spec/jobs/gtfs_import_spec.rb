require 'rails_helper'

RSpec.describe GtfsImport, type: :job do
  describe "#perform" do
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
    let(:schedule){ TransitSchedule.latest }

    before(:each) do
      stub_request(:get, source_url).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => "xyz", :headers => headers)

      allow(Zip::File).to receive(:open).and_return(Zip::File.open("./spec/data/mock_google_transit.zip"))

      described_class.perform(:source_url => source_url)
    end

    it "should persist transit schedule metadata" do
      expect(schedule.published_at.to_datetime).to eql(headers["last-modified"].first.to_datetime)
      expect(schedule.content_length).to eql(headers["content-length"].first.to_i)
      expect(schedule.etag).to eql(headers["etag"].first.tr('"',''))
    end

    it "should persist transit schedule data" do
      expect(Agency.count).to be > 0
      expect(Calendar.count).to be > 0
      expect(CalendarDate.count).to be > 0
      expect(Route.count).to be > 0
      expect(Stop.count).to be > 0
      expect(StopTime.count).to be > 0
      expect(Trip.count).to be > 0

      expect(Train.count).to be > 0
    end
  end
end

require 'rails_helper'

RSpec.describe GtfsImport, type: :job do
  describe "#perform" do
    let(:headers){
      {
        "date"=>["Fri, 30 Dec 2016 23:50:31 GMT"],
        "server"=>["Apache/2.4.10 (FreeBSD) OpenSSL/1.0.1j PHP/5.4.35"],
        "last-modified"=>["Tue, 29 Nov 2016 16:58:01 GMT"],
        "etag"=>["\"1ac9-542737db15840\""],
        "accept-ranges"=>["bytes"],
        "content-length"=>["6857"],
        "connection"=>["close"],
        "content-type"=>["application/zip"]
      }
    }
    let(:latest_transit_schedule){ TransitSchedule.latest }

    before(:each) do
      described_class.perform
    end

    it "should persist metadata about when the feed was last modified" do
      expect(latest_transit_schedule.published_at.to_datetime).to eql(headers["last-modified"].first.to_datetime)
    end

    it "should persist metadata about file size" do
      expect(latest_transit_schedule.content_length).to eql(headers["content-length"].first.to_i)
    end

    #context "when hosted schedule and system schedule published at same time" do
    #  it "should send an email notification" do
    #    pending
    #  end
    #end

    #context "when hosted schedule published after system schedule" do
    #  it "should update system schedule" do
    #    expect{described_class.perform}.to change{Train.count}.from(0).to(999)
    #  end
#
    #  it "should send an email notification" do
    #    pending
    #  end
    #end
  end
end

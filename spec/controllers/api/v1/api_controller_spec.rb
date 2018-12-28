require 'rails_helper'
require_relative '../../../support/api_response_helpers'
require_relative '../../../support/gtfs_import_helpers'

RSpec.describe Api::V1::ApiController, type: :controller do
  describe "#trains response" do
    context "when receiving no parameters" do
      let(:response){  get(:trains, params: {format: 'json'})  }

      it "should indicate the query parameters it received" do
        expect(parsed_response[:query]).to eql({})
      end

      it "should contain error messages prompting the user to specify parameter values" do
        expect(parsed_response[:errors]).to_not be_blank
        expect(parsed_response[:errors]).to have_content("Please specify an origin station abbreviation")
        expect(parsed_response[:errors]).to have_content("Please specify a destination station abbreviation")
        expect(parsed_response[:errors]).to have_content("Please specify a departure date")
      end

      it "should not contain any results" do
        expect(parsed_response[:results]).to be_blank
      end
    end

    context "when receiving invalid parameters" do
      let(:response){  get(:trains, params: {format: 'json', origin: 'ABC', destination: 'DEF', date: '2day'})  }

      it "should indicate the query parameters it received" do
        expect(parsed_response[:query]).to eql({:origin=>"ABC", :destination=>"DEF", :date=>"2day"})
      end

      it "should contain error messages notifying the user of parameter invalidity" do
        expect(parsed_response[:errors]).to_not be_blank
        expect(parsed_response[:errors]).to have_content("Invalid origin station abbreviation")
        expect(parsed_response[:errors]).to have_content("Invalid destination station abbreviation")
        expect(parsed_response[:errors]).to have_content("Invalid departure date")
      end

      it "should not contain any results" do
        expect(parsed_response[:results]).to be_blank
      end
    end

    context "when receiving valid parameters" do
      let(:active_schedule){ create(:schedule, :active) }
      let!(:origin){ create(:stop, :guid => "BRN", :schedule_id => active_schedule.id)}
      let!(:destination){ create(:stop, :guid => "ST", :schedule_id => active_schedule.id)}

      let(:response){  get(:trains, params: {format: 'json', origin: 'BRN', destination: 'ST', date: '2016-12-28'})  }

      it "should indicate the query parameters it received" do
        expect(parsed_response[:query]).to eql({:origin=>"BRN", :destination=>"ST", :date=>"2016-12-28"})
      end

      it "should not contain any error messages" do
        expect(parsed_response[:errors]).to be_blank
      end

      context "when results exist" do
        let(:source_url){ "http://www.my-site.com/gtfs-feed.zip"}
        let(:import){ GtfsImport.new(:source_url => source_url)}
        let(:first_result){ parsed_response[:results].first }

        let(:time_zone_offset) { Time.zone.now.formatted_offset } #> -04:00 or -05:00 depending on DST

        before(:each) do
          stub_download_zip(source_url)
          import.perform
        end #TODO: define factories to avoid overburdening test suite with zip-file-processing

        it "should contain results" do
          expect(parsed_response[:results]).to_not be_blank
          expect(first_result).to include({
            :schedule_id => active_schedule.id + 1,
            :service_guid=>"WD",
            :trip_guid=>"1627",
            :route_guid=>"SLE",
            :trip_headsign=>"Westbound",
            :origin_departure=>"2016-12-28T06:07:00#{time_zone_offset}",
            :destination_arrival=>"2016-12-28T06:20:00#{time_zone_offset}",
            :stops=>[
              {:stop_sequence=>68, :stop_guid=>"OSB",   :arrival_time=>"2016-12-28T05:37:00#{time_zone_offset}", :departure_time=>"2016-12-28T05:37:00#{time_zone_offset}"},
              {:stop_sequence=>69, :stop_guid=>"WES",   :arrival_time=>"2016-12-28T05:42:00#{time_zone_offset}", :departure_time=>"2016-12-28T05:42:00#{time_zone_offset}"},
              {:stop_sequence=>70, :stop_guid=>"CLIN",  :arrival_time=>"2016-12-28T05:47:00#{time_zone_offset}", :departure_time=>"2016-12-28T05:47:00#{time_zone_offset}"},
              {:stop_sequence=>71, :stop_guid=>"MAD",   :arrival_time=>"2016-12-28T05:52:00#{time_zone_offset}", :departure_time=>"2016-12-28T05:52:00#{time_zone_offset}"},
              {:stop_sequence=>72, :stop_guid=>"GUIL",  :arrival_time=>"2016-12-28T05:58:00#{time_zone_offset}", :departure_time=>"2016-12-28T05:58:00#{time_zone_offset}"},
              {:stop_sequence=>73, :stop_guid=>"BRN",   :arrival_time=>"2016-12-28T06:07:00#{time_zone_offset}", :departure_time=>"2016-12-28T06:07:00#{time_zone_offset}"},
              {:stop_sequence=>74, :stop_guid=>"ST",    :arrival_time=>"2016-12-28T06:20:00#{time_zone_offset}", :departure_time=>"2016-12-28T06:20:00#{time_zone_offset}"},
              {:stop_sequence=>75, :stop_guid=>"NHV",   :arrival_time=>"2016-12-28T06:22:00#{time_zone_offset}", :departure_time=>"2016-12-28T06:22:00#{time_zone_offset}"}
            ]
          })
        end
      end

      #context "when no results exist" do
      #  it "should contain an error message" do
      #    expect(parsed_response[:errors]).to_not be_blank
      #  end
      #end
    end
  end
end

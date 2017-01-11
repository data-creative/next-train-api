require 'rails_helper'
require_relative '../../../support/api_response_helpers'
require_relative '../../../support/gtfs_import_helpers'

RSpec.describe Api::V1::ApiController, type: :controller do
  describe "#trains response" do
    context "when given no parameters" do
      let(:response){  get(:trains, params: {format: 'json'})  }

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

    context "when given invalid parameters" do
      let(:response){  get(:trains, params: {format: 'json', origin: 'ABC', destination: 'DEF', date: '2day'})  }

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

    context "when given valid parameters" do
      let(:response){  get(:trains, params: {format: 'json', origin: 'BRN', destination: 'ST', date: '2016-12-28'})  }

      it "should not contain any error messages" do
        expect(parsed_response[:errors]).to be_blank
      end

      context "when results exist" do
        let(:source_url){ "http://www.my-site.com/gtfs-feed.zip"}
        let(:import){ GtfsImport.new(:source_url => source_url)}

        before(:each) do
          stub_download_zip(source_url)
          import.perform
        end

        it "should contain results" do
          expect(parsed_response[:results]).to_not be_blank
          #expect(parsed_response[:results].first[:origin_departure]).to include("2016-12-28 05:40:00")
          #expect(parsed_response[:results].first[:destination_arrival]).to include("2016-12-28 05:53:00")
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

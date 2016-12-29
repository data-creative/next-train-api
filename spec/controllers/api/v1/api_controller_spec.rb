require 'rails_helper'
require_relative '../../../support/api_response_helpers'

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

      it "should contain results" do
        expect(parsed_response[:results]).to_not be_blank

        #TODO: expect mock data
        #expect(parsed_response[:results]).to have_content("5:40")
        #expect(parsed_response[:results]).to have_content("5:53")
      end
    end
  end
end

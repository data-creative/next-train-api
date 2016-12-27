require 'rails_helper'
require_relative '../../../support/api_response_helpers'

RSpec.describe Api::V1::ApiController, type: :controller do
  describe "#trains response" do
    context "when no parameters are passed" do
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
  end
end

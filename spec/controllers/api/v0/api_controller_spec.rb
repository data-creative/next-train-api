require 'rails_helper'
require_relative '../../../support/api_response_helpers'

RSpec.describe Api::V0::ApiController, type: :controller do
  let(:token){ "ABC-1234-5678-XYZ" }

  describe "#index" do
    let(:response){  get(:index, params: {format: 'json', token: token})  }

    it "should return a successful and appropriate response" do
      expect_successful_response
      expect(parsed_response).to have_content("World")
    end

    context "when passed url parameters" do
      let(:response){  get(:index, params: {format: 'json', token: token, hello:'Wurld'})  }

      it "should return a successful and appropriate response" do
        expect_successful_response
        expect(parsed_response).to have_content("Wurld")
      end
    end
  end

  describe "#stations" do
    let(:response){  get(:stations, params: {format: 'json', token: token})  }

    it "should return a successful and appropriate response" do
      expect_successful_response
      expect(parsed_response).to have_content("CT")
    end

    context "when passed url parameters" do
      let(:response){  get(:stations, params: {format: 'json', token: token, geo: 'GEORGIA'})  }

      it "should return a successful and appropriate response" do
        expect_successful_response
        expect(parsed_response).to have_content("GEORGIA")
      end
    end
  end

  describe "#trains" do
    let(:response){  get(:trains, params: {format: 'json', token: token})  }

    it "should return a successful and appropriate response" do
      expect_successful_response
      expect(parsed_response).to have_content("NHV")
      expect(parsed_response).to have_content("BRN")
      expect(parsed_response).to have_content(Date.today.to_s)
    end

    context "when passed url parameters" do
      let(:response){  get(:trains, params: {format: 'json', token: token, origin: 'GCT', destination: 'ZZZ', date: '2016-10-24'})  }

      it "should return a successful and appropriate response" do
        expect_successful_response
        expect(parsed_response).to have_content("GCT")
        expect(parsed_response).to have_content("ZZZ")
        expect(parsed_response).to have_content('2016-10-24')
      end
    end
  end
end

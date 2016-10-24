require 'rails_helper'
require_relative '../../../support/api_response_helpers'

RSpec.describe Api::V1::ApiController, type: :controller do
  let(:token){ "ABC-1234-5678-XYZ" }

  describe "#index" do
    let(:response){  get(:index, params: {format: 'json', token: token})  }

    it "should return a successful response" do
      expect_successful_response
    end
  end

  describe "#stations" do
    let(:response){  get(:stations, params: {format: 'json', token: token, geo: 'CT'})  }

    it "should return a successful response" do
      expect_successful_response
    end
  end

  describe "#trains" do
    let(:response){  get(:trains, params: {format: 'json', token: token, origin: 'NHV', destination: 'BRN', date: '2016-10-24'})  }

    it "should return a successful response" do
      expect_successful_response
    end
  end
end

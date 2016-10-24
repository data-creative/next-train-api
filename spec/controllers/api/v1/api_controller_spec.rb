require 'rails_helper'

RSpec.describe Api::V1::ApiController, type: :controller do
  let(:token){ nil }
  let(:response){
    rsp = get :stations, params: {format: 'json', api_key: token}
    binding.pry
    JSON.parse(rsp.body)
  }

  #before(:each) do
  #  @request.env["devise.mapping"] = Devise.mappings[:developer]
  #  developer = create(:developer)
  #  developer.confirm
  #  login_as(developer, scope: 'developer')
  #end

  #context "when request does not contain an api key" do
  #  it "should return MissingApiKeyError" do
  #    matching_error_messages = response["errors"].select{|str| str.include?("MissingApiKeyError")}
  #    expect(matching_error_messages).to_not be_empty
  #  end
#
  #  it "should not return any results" do
  #    expect(response["results"]).to be_empty
  #  end
  #end

  #context "when request contains an unrecognized api key" do
  #  let(:token){"idksomething"}
#
  #  it "should return UnrecognizedApiKeyError" do
  #    matching_error_messages = response["errors"].select{|str| str.include?("UnrecognizedApiKeyError")}
  #    expect(matching_error_messages).to_not be_empty
  #  end
#
  #  it "should not return any results" do
  #    expect(response["results"]).to be_empty
  #  end
  #end

  context "when request contains a recognized, unrevoked api key" do
    let(:token){ "ABC-1234-5678-XYZ"}

    it "should not return any errors" do
      expect(response["errors"]).to be_empty
    end

    it "should return results" do
      expect(response["results"]).to_not be_empty
    end

    #context "when request contains an unrecognized search parameter" do
    #  let(:response){
    #    rsp = get :stations, {"format"=>"json", "api_key"=>token, "my_param"=>"MyValue"}
    #    JSON.parse(rsp.body)
    #  }
#
    #  it "should return UnrecognizedEventSearchParameter" do
    #    matching_error_messages = response["errors"].select{|str| str.include?("UnrecognizedEventSearchParameter")}
    #    expect(matching_error_messages).to_not be_empty
    #  end
#
    #  it "should not return any results" do
    #    expect(response["results"]).to be_empty
    #  end
    #end
  end

end

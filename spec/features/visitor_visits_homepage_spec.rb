require 'rails_helper'

RSpec.describe "Visitor Visits Homepage", type: :feature do
  describe "#index" do
    before(:each) do
      visit root_path
    end

    it "should contain a welcome message" do
      expect(page).to have_content("Hello World")
    end

    it "should contain a link to the source code" do
      expect(page).to have_content("Source Code")
    end

    it "should contain a sign-up link" do
      expect(page).to have_content("Register for an API key")
    end
  end
end

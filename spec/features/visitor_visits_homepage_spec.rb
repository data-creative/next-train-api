require 'rails_helper'

RSpec.describe "Visitor Visits Homepage", type: :feature do
  describe "#index" do
    before(:each) do
      visit root_path
    end

    it "should contain a sign-in link" do
      expect(page).to have_content("Sign In")
    end

    it "should contain a sign-up link" do
      expect(page).to have_content("Sign Up")
    end

    it "should contain a link to the source code" do
      expect(page).to have_content("Source Code")
    end
  end
end

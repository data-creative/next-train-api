require 'rails_helper'

RSpec.describe "Visitor Visits Homepage", type: :feature do
  describe "#index" do
    before(:each) do
      visit root_path
    end

    it "should contain a welcome message" do
      expect(page).to have_content("Hello World")
    end
  end
end

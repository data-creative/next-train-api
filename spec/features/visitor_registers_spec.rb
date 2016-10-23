require 'rails_helper'

RSpec.describe "Visitor Registers", type: :feature do
  before(:each) do
    visit root_path
    click "Register for an API key"
  end

  it "should redirect to a sign-up form" do
    expect(page).to have_content("Sign Up")
  end
end

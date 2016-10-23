require 'rails_helper'

RSpec.describe "Visitor Registers", type: :feature do
  before(:each) do
    visit root_path
    click_link("Sign Up")
  end

  it "should redirect to a sign-up form" do
    expect(page).to have_css("h2", text: "Sign up")
    expect(page).to have_css("form", class: "new_developer")
    expect(page).to have_css("input", id: "developer_email")
    expect(page).to have_css("input", id: "developer_password")
    expect(page).to have_css("input", id: "developer_password_confirmation")
  end
end

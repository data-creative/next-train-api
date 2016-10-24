require 'rails_helper'

RSpec.describe "Visitor Registers", type: :feature do
  describe "Sign-up form" do
    it "should be navigatable from the homepage" do
      visit root_path
      click_link("Sign Up")
      expect_sign_up_form
    end

    context "when filled-in and submitted with valid credentials" do
      before(:each) do
        visit new_developer_registration_path
        within(".new_developer") do
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Password', with: 'mypass123'
          fill_in 'Password confirmation', with: 'mypass123'
        end

        click_button 'Sign up'
      end

      it "should redirect the visitor to the homepage" do
        expect(page.current_path).to eql(root_path)
      end

      it "should instruct the visitor via flash message to check email for a confirmation link" do
        expect(page).to have_content("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
      end
    end
  end

  def expect_sign_up_form
    expect(page).to have_css("h2", text: "Sign up")
    expect(page).to have_css("form", class: "new_developer")
    expect(page).to have_css("input", id: "developer_email")
    expect(page).to have_css("input", id: "developer_password")
    expect(page).to have_css("input", id: "developer_password_confirmation")
  end

end

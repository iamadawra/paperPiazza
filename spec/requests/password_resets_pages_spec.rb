require 'spec_helper'

describe "Password Resets" do

  subject { page }

  describe "login page" do

    before { visit login_path }

    it { should have_link("Forgot your password", href: new_password_reset_path) }

  end

  describe "password reset page" do

    before { visit new_password_reset_path }

    it { should have_selector("h1", text: "Reset your password") }
    it { should have_selector("title", text: full_title("Reset Your Password")) }

  end

  describe "start password reset" do

    let(:user) { create(:user) }

    before do
      visit login_path
      click_link "password"
    end

    it { should have_selector("title", text: "Reset Your Password") }

    describe "with an existing email address" do
      before do
        fill_in "Email", with: user.email
        click_button "Submit"
      end

      it { should have_info_message(text: "sent to your email address") }
      specify { last_email.to.should include(user.email) }
    end

    describe "with a nonexistant email address" do
      before do
        fill_in "Email", with: user.email + "e"
        click_button "Submit"
      end

      it { should have_info_message(text: "sent to your email address") }
      specify { last_email.should be_nil }
    end

  end

  describe "complete password reset with valid token" do
    let(:user) { create(:user, perishable_token: "token", password_reset_sent_at: 1.hour.ago) }
    before do
      visit edit_password_reset_path(user.perishable_token)
      fill_in "Password",               with: "password"
    end

    it { should have_selector("title", text: "Reset Your Password") }

    describe "without password confirmation" do
      before { click_button "Reset Password" }
      it { should have_content("Password doesn't match confirmation") }
    end

    describe "with password matching confirmation" do
      before do
        fill_in "Password confirmation",  with: "password"
        click_button "Reset Password"
      end
      it { should have_success_message(text: "password has been reset") }

      describe "then trying to log in" do
        before do
          visit login_path
          fill_in "Email",    with: user.email
          fill_in "Password", with: "password"
          click_button "Log In"
        end

        it { should have_link("Your Account") }
        it { should_not have_link("Log In") }
        it { should have_link("Log Out") }
      end

    end
  end

  describe "complete password reset with expired token" do
    let(:user) { create(:user, perishable_token: "token", password_reset_sent_at: 5.hour.ago) }

    it "should report that the token has expired" do
      visit edit_password_reset_path(user.perishable_token)
      fill_in "Password",               with: "password"
      fill_in "Password confirmation",  with: "password"
      click_button "Reset Password"
      page.should have_error_message(text: "has expired")
      current_path.should eq(new_password_reset_path)
    end
  end

  describe "complete password reset with invalid token" do
    before do
      visit edit_password_reset_path("invalid")
    end
    it "should redirect to password reset page" do
      page.should have_error_message(text: "was invalid")
      current_path.should eq(new_password_reset_path)
    end
  end
end

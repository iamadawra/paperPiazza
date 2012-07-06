require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "login page" do

    before { visit login_path }

    it { should have_selector("h1",     text: "Log In") }
    it { should have_selector("title",  text: full_title("Log In")) }

  end

  describe "login" do

    before { visit login_path }

    describe "with invalid information" do
      before { click_button "Log In" }

      it { should have_selector("title", text: full_title("Log In")) }
      it { should_not have_link("Your Account") }
      it { should_not have_link("Log Out") }
      it { should have_error_message(text: "Invalid") }

      describe "after visiting another page" do
        before { click_link "Register" }
        it { should_not have_error_message }
      end
    end

    describe "with valid information" do

      let(:user) { create(:user) }
      before do
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
      end

      describe "with remember me unchecked" do

        before { click_button "Log In" }

        it { should have_link("Log Out",      href: logout_path) }
        it { should_not have_link("Log In",   href: login_path) }

        describe "followed by logout" do
          before { click_link "Log Out" }
          it { should have_link('Log In') }
        end

        pending "check remember not permanent"

      end

      # Shouldn't need to repeat most of the tests from when remember me is unchecked.
      describe "with remember me checked" do
        before do
          check("Remember me")
          click_button "Log In"
        end

        pending "check remember is permanent"
      end

    end

  end

  describe "logout" do
    let(:user) { create(:user) }
    before do
      log_in user
      click_link "Log Out"
    end

    describe "should redirect to root" do
      # The invalid password message showed up at one point because the root
      # route was wrong. This ensures this doesn't happen.
      it { should_not have_error_message }
      specify { current_path.should eq(root_path) }
    end

  end

end

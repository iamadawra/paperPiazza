require 'spec_helper'

describe "Account pages:" do

  subject { page }

  describe "register" do

    before { visit register_path }

    it { should have_selector('h1',     text: 'Register') }
    it { should have_selector('title',  text: full_title('Register')) }
    it { should have_link('Log In') }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button "Create Your Account" }.not_to change(User, :count)
      end
    end

    describe "without a confirmed password" do
      let(:user) { build(:user) }
      before do
        fill_in "Name",         with: user.name
        fill_in "Email",        with: user.email 
        fill_in "Password",     with: user.password
      end
      it "should not create a user" do
        expect { click_button "Create Your Account" }.not_to change(User, :count)
      end
    end

    describe "with a duplicate email" do
      let(:user) { create(:user) }
      before do
        fill_in "Name",         with: user.name
        fill_in "Email",        with: user.email 
        fill_in "Password",     with: user.password
        fill_in "confirmation", with: user.password
      end
      it "should not create a user" do
        expect { click_button "Create Your Account" }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      let(:user) { build(:user) }
      before do
        fill_in "Name",         with: user.name
        fill_in "Email",        with: user.email 
        fill_in "Password",     with: user.password
        fill_in "confirmation", with: user.password
      end

      it "should create a user" do
        expect { click_button "Create Your Account" }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button "Create Your Account" }
        let(:found_user) { User.find_by_email(user.email) }

        it { should have_success_message(text: "Welcome") }
        it { should have_selector('h2', text: found_user.name) }
        it { should have_link('Log Out', href: logout_path) }
      end

    end

  end

  describe "show" do
    let(:user) { create(:user) }
    before do
      log_in user
      visit account_path
    end
    it { should have_selector('h1', text: "Your Account") }
    it { should have_selector('title', text: "Your Account") }
    it { should have_selector('h2', text: user.name) }
    it { should have_content(user.email) }
  end

  describe "edit" do
    let(:user) { create(:user) }
    before do
      log_in user
      visit account_path
      click_link "Edit Your Account"
    end

    it { should have_selector('h1', text: "Editing Your Account") }
    it { should have_selector('title', text: "Editing Your Account") }

    it "should let you update your email without requiring a password" do
      fill_in "Email", with: "newemail@new.com"
      fill_in "Password", with: ""
      click_button "Submit"
      current_path.should eq(account_path)
      page.should have_success_message(text: "updated")
      page.should have_content("newemail@new.com")
    end

    it "should let you update your password" do
      fill_in "Password", with: "newpass"
      fill_in "Password confirmation", with: "newpass"
      click_button "Submit"
      current_path.should eq(account_path)
      page.should have_success_message(text: "updated")
    end

    it "should require password confirmation" do
      fill_in "Password", with: "newpass"
      click_button "Submit"
      page.should have_content("Password doesn't match confirmation")
    end

  end

end

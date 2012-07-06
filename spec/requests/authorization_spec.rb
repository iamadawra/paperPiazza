require 'spec_helper'

describe "Authorization" do

  describe "for authentication" do
    let(:user) { create(:user) }
    describe "for a signed in user" do
      before { log_in user }
      describe "visiting the login page" do
        before { visit login_path }
        specify { page.should_not have_selector('title', text: 'Log In') }
        specify { current_path.should eq(account_path) }
      end
      pending "test that posting to the user session create doesn't change the logged in user"
    end
  end

  describe "for a non-signed-in user" do
    let(:user) { create(:user) }

    describe "when attempting to visit a protected page" do
      before do
        visit edit_account_path
        fill_in "Email",    with: user.email
        fill_in "Password", with: user.password
        click_button "Log In"
      end

      describe "after signing in" do
        it "should render the desired protected page" do
          current_path.should eq(edit_account_path)
          page.should have_selector('title', text: 'Editing Your Account')
        end
      end

    end
  end

  describe "for an account" do
    let(:user) { create(:user) }

    describe "for a non-signed-in user"  do
      describe "visiting the show page" do
        before { visit account_path }
        specify { page.should have_notice_message(text: "must be logged in") }
        specify { page.should have_selector('title', text: 'Log In') }
        specify { current_path.should eq(login_path) }
      end

      describe "visiting the edit page" do
        before { visit edit_account_path }
        specify { page.should have_notice_message(text: "must be logged in") }
        specify { page.should have_selector('title', text: 'Log In') }
        specify { current_path.should eq(login_path) }
      end

      describe "submitting to the update action" do
        before { put account_path }
        specify { response.should redirect_to(login_path) }
      end

      describe "visiting the new page" do
        before { visit new_account_path }
        specify { current_path.should eq(new_account_path) }
      end

      describe "submitting to the create action" do
        it "should create a user" do
          # Need to filter out admin attribute because it's not mass assignable.
          expect { post account_path, user: attributes_for(:user).reject {|k| k == :admin} }.to change(User, :count).by(1)
        end
      end
    end

    describe "for a signed-in user" do
      before { log_in user }
      describe "visiting the show page" do
        before { visit account_path }
        specify { current_path.should eq(account_path) }
      end

      describe "visiting the edit page" do
        before { visit edit_account_path }
        specify { current_path.should eq(edit_account_path) }
      end

      describe "submitting to the update action" do
        before { put account_path }
        specify { response.should_not redirect_to(login_path) }
        specify { response.should     redirect_to(account_path) }
      end

      describe "visiting the new page" do
        before { visit new_account_path }
        specify { page.should have_notice_message(text: "must be logged out") }
        specify { current_path.should eq(account_path) }
      end

      describe "submitting to the create action" do
        it "should not create a user" do
          expect { post account_path, user: attributes_for(:user) }.not_to change(User, :count)
        end
      end
    end

  end
  # TODO invalid assn spec

end

require 'spec_helper'

describe "Layout" do

  subject { page }

  describe "for a non-signed-in user" do
    before { visit account_path }
    it { should have_link("Log In") }
    it { should have_link("Register") }
    it { should have_link("Browse Courses") }
  end

  describe "for a signed-in user" do
    let(:user) { create(:user) }
    before { log_in user }

    it { should have_link("Log Out") }
    it { should have_link("Your Account") }

    describe "should have a course menu" do

      subject { find("#course_menu") }

      describe "when the user has no courses" do
        it { should_not have_link("CS 188") }
        it { should     have_link("Browse Courses") }
      end

      describe "when the user has courses" do

        let(:courses) { create_courses }

        before do
          join_courses(courses[0,2])
          visit courses_path
        end

        it { should     have_link("#{courses[0].to_short_s}") }
        it { should     have_link("#{courses[1].to_short_s}") }
        it { should_not have_link("#{courses[2].to_short_s}") }
        it { should     have_link("Browse Courses") }
      end

    end

  end

end

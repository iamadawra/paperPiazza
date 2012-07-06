# == Schema Information
#
# Table name: courses
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  shortname   :string(255)
#  term        :string(255)
#  description :text
#  year        :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null

require 'spec_helper'

describe "Courses pages:" do

  subject { page }

  describe "new" do
    let(:user) { create(:user) }
    before do
      log_in user
      visit new_course_path
    end

    it { should have_selector("title",   text: "Create Course") }
    it { should have_selector("h1",      text: "Create Your Course") }
    it { should have_field("Name",        with: nil) }
    it { should have_field("Short Name",  with: nil) }
    it { should have_field("Description", with: nil) }
    it { should have_select("course_term", selected: nil) }
    it { should have_select("course_year", selected: nil) }

    describe "with invalid information" do
      it "should not create a course" do
        expect { click_button "Create Course" }.not_to change(Course, :count)
        expect { page.should have_error_message :text=>'There was a problem creating your course.'}
      end
    end

    describe "with no name" do
      let(:course) { build(:course) }

      before do
        fill_in "Description",  with: course.description
        fill_in "Short Name",   with: course.shortname
        select  course.term,      from: "Term"
        select  course.year.to_s, from: "Year"
      end

      it "should not create a course" do
        expect { click_button "Create Course" }.not_to change(Course, :count)
      end

      it "should render the form with an error message" do
        click_button "Create Course"
        page.should have_selector("select", text: Time.now.year.to_s)
        page.should have_error_message(text: "fix the following")
      end
    end

    describe "with valid information" do
      let(:course) { build(:course) }

      before do
        fill_in "Name",         with: course.name
        fill_in "Description",  with: course.description
        fill_in "Short Name",   with: course.shortname
        select  course.term,      from: "Term"
        select  course.year.to_s, from: "Year"
      end

      it "should create a course" do
        expect { click_button "Create Course" }.to change(Course, :count).by(1)
      end

      describe "after creating the course" do

        before { click_button "Create Course" }

        it "should redirect to the course page" do
          page.should have_success_message(text: course.name)
          page.should have_selector("title",  text: course.name)
          page.should have_selector("h1",     text: course.name)
          page.should have_selector("p",      text: course.description)
        end

        it "should have the current user as an instructor" do
          page.should have_selector("h2",   text: user.name)
        end

      end

    end
  end

  describe "show" do
    let(:user) { create(:user) }
    let(:course_membership) { create(:instructor_membership, user: user) }
    let(:course) { course_membership.course }
    before do
      log_in user
      visit course_path(course)
    end

    it { should have_selector("title",  text: course.name) } 
    it { should have_selector("h1",     text: course.name) } 
    it { should have_selector("p",      text: course.description) }

    describe "after clicking the edit button" do
      before { click_link "Edit Course" }
      it "should redirect you to the edit page" do
        current_path.should eq(edit_course_path(course))
      end
    end

  end

  describe "edit" do
    let(:user) { create(:user) }
    let(:course_membership) { create(:instructor_membership, user: user) }
    let(:course) { course_membership.course }
    before do
      log_in user
      visit edit_course_path(course)
    end

    it { should have_selector("title",   text: "Editing Course Information") }
    it { should have_selector("h1",      text: "Editing Course Information") }
    it { should have_field("Name",        with: course.name) }
    it { should have_field("Short Name",  with: course.shortname) }
    it { should have_field("Description", with: course.description) }
    it { should have_select("course_term",  selected: course.term) }
    it { should have_select("course_year",  selected: course.year.to_s) }

    describe "with invalid information" do
      it "should render the form with an error message" do
        fill_in "Name", with: ""
        click_button "Update"
        page.should have_select("course_year", selected: course.year.to_s)
        page.should have_error_message(text: "fix the following")
      end
    end

    describe "with valid information" do
      it "should update the course" do
        fill_in "Name", with: course.name + " (advanced)"
        click_button "Update"
        page.should have_selector("title",  text: course.name + " (advanced)")
        page.should have_selector("h1",     text: course.name + " (advanced)")
        page.should have_success_message(text: "Updated")
      end
    end
  end

  describe "index" do

    let!(:courses) { create_courses }

    before do 
      visit courses_path
    end

    it { should have_selector('title',  text: "Courses") }
    it { should have_selector('h1',     text: "Browsing Courses") }

    it { should have_link('Create a Course', href: new_course_path) }

    it "should list the existing courses" do
      courses.each do |course|
        page.should have_content(course.name)
        page.should have_link(course.name, href: course_path(course))
      end
    end

    describe "with a logged in user" do
      let(:user) { create(:user) }
      before do
        log_in user
        visit courses_path
      end

      it "should create a membership when joining a course" do
        expect { click_button "join_course#{courses[1].id}" }.to change(CourseMembership, :count).by(1)
      end

      describe "when the user joins a course" do
        before do
          click_button "join_course#{courses[2].id}"
        end

        it "should redirect to the course page" do
          current_path.should eq(course_path(courses[2]))
        end

        it "should not have the student as an instructor" do
          page.should_not have_content(user.name)
        end

        describe "when revisiting the index page" do

          before { visit courses_path }

          it "should destroy a membership when leaving a course" do
            expect { click_link "leave_course#{courses[2].id}" }.to change(CourseMembership, :count).by(-1)
          end

          it { should_not have_button("join_course#{courses[2].id}") }
          it { should     have_link("leave_course#{courses[2].id}") }

          describe "after leaving the course" do
            before { click_link "leave_course#{courses[2].id}" }

            it "should redirect to the course index" do
              current_path.should eq(courses_path)
            end

            it { should     have_button("join_course#{courses[2].id}") }
            it { should_not have_link("leave_course#{courses[2].id}") }

          end


        end

      end
    end
  end

end

require 'spec_helper'

describe "Assignment pages:" do

  subject { page }

  describe "new", :js=>true do
    let(:current_user) { create(:user) }
    let!(:course) { create(:course) }
    let!(:question1) { create(:multiple_choice_question, course: course) }
    let!(:question2) { create(:select_all_question, course: course) }

    before do
      create(:instructor_membership, user: current_user, course: course)
      log_in current_user
      visit new_course_assignment_path course
    end

    it { should have_selector("#assignment_title") }

    describe "with no questions added" do
      def self.should_create_an_assignment(&block)
        it "should create an assignment" do
          instance_eval(&block) if block_given?

          old_count = Assignment.count

          click_button "Create assignment"

          page.should have_selector("h3", text: @title)
          Assignment.count.should eq(old_count+1)
        end
      end

      describe "when given a title, release date, and due date in the future"do
        before do
          fill_in 'assignment_title', :with => 'An Assignment'
          fill_in_date_fields('assignment_release_date', Time.now)
          fill_in_date_fields('assignment_due_date', Time.now+1.day)
        end

        should_create_an_assignment
      end

      describe "when given a title, resubmit delay, release_date, due date" do
        before do
          @title = 'An Assigment'
          fill_in 'assignment_title', :with => @title
          fill_in_date_fields('assignment_release_date', Time.now)
          fill_in_date_fields('assignment_due_date', Time.now+1.day)
          fill_in 'assignment_resubmit_delay', :with => 42
        end

        should_create_an_assignment do
          fill_in 'assignment_resubmit_delay', :with => 42
        end

        describe "and I've selected a question and given it a resubmit delay" do
          before do
            @delay = 43
            find("#question_#{question1.id}").click
            page.should have_selector("#question_resubmit_delay")
            fill_in "question_resubmit_delay", :with => @delay

            @old_count = Assignment.count

            click_link "Add Question"
            click_button "Create assignment"
          end

          it "should create an assignment with an entry" do
            page.should have_selector("h3", text: @title)
            Assignment.count.should == @old_count + 1

            Assignment.last.entries.count.should == 1
            Assignment.last.entries.last.resubmit_delay == @delay
          end
        end

      end
    end

    describe "with questions added" do
      before do
        find("#question_#{question1.id}").click
        click_link "Add Question"
        find("#question_#{question2.id}").click
        click_link "Add Question"
      end

      it "should have added the questions" do
        page.should have_selector("#question_ids_#{question1.id}")
        page.should have_selector("#question_ids_#{question2.id}")
      end

      it "should not be valid without a title" do
        expect { click_button "Create assignment" }.not_to change(Assignment, :count)
        page.should have_error_message(text: "fix the following error")
      end

      it "should not be valid with a due date not in the future" do
        fill_in 'assignment_title', :with => 'An Assignment'
        expect { click_button "Create assignment" }.not_to change(Assignment, :count)
        page.should have_error_message(text: 'fix the following error')
      end

      it "should create an assignment when given a due date in the future" do
        fill_in 'assignment_title', :with => 'An Assignment'
        fill_in_date_fields('assignment_release_date', Time.now)
        fill_in_date_fields('assignment_due_date', Time.now+1.day)
        old_count = Assignment.count
        click_button "Create assignment"
        # This is used because of a race condition with capybara-webkit. have_selector blocks until it finds the element
        page.should have_selector('h3', text: 'An Assignment')
        Assignment.count.should == old_count + 1
      end

      describe "when I go to create an Assignment" do
        before do
          click_button "Create assignment"
        end

        it "should see both Questions still attached to the Assignment" do
          within("#selected_questions") do
            all(".question_list_item").size.should == 2
          end
        end

        it "should see no Questions available for selection" do
          within("#question_id") do
            all(".question_item").size.should == 0
          end
        end

        describe "after being returned to the 'new' page, I fill in a title and due date in the future and submit the assignment" do
          before do
            fill_in 'assignment_title', :with => 'An Assignment'
            fill_in_date_fields('assignment_release_date', Time.now)
            fill_in_date_fields('assignment_due_date', Time.now+1.year)
            @old_count = Assignment.count
            click_button "Create assignment"
          end

          it "has created the assignment" do
            page.should have_selector('h3', text: 'An Assignment')
            Assignment.count.should == @old_count + 1
          end

          it "has created the assignment's entries" do
            page.should have_selector('h3', text: 'An Assignment')
            Assignment.last.entries.count.should == 2
          end
        end
      end
    end

    describe "with embedded question editor" do

      before do
        click_link "Create New Question"
      end

      it_should_behave_like "standard question page",
        :selectors => [".question_editor>#editor", "#save_new_question"]

      it_should_behave_like "select all question page",
        :btn_create_question => "Save Question"

      it_should_behave_like "multiple choice question page",
        :btn_create_question => "Save Question"
    end
  end

  describe "index" do
    let(:current_user) { create(:user) }
    let(:course) { create(:course) }
    let!(:unpublished_assignment) { create :assignment_with_questions,
                                    course: course }
    let!(:published_assignment) do
      create :published_assignment_with_questions,
              course: course
    end
    describe "for a student" do
      before do
        create(:student_membership, user: current_user, course: course)
        log_in current_user
        visit course_assignments_path course
      end
      it { should have_content(published_assignment.title) }
      it { should_not have_content(unpublished_assignment.title) }
    end
  end

  describe "show" do
    let(:current_user)  { create(:user) }
    let(:course)        { create(:course) }
    let(:assignment)    { create(:published_assignment_with_questions,
                                  course: course) }
    before do
      create(:student_membership, user: current_user, course: course)
      log_in current_user
      visit course_assignment_path course, assignment
    end

    it { should have_selector('h3', text: assignment.title) }
    it { should have_selector('h4', text: assignment.due_date.to_s(:due)) }

    it "should have a sidebar to navigate between questions" do
      page.should have_selector('#assignment_sidebar', text: 'Question 1')
    end

    it "should have question text on the page" do
      page.should have_content(assignment.questions[-1].text)
    end
  end

  describe "a student taking an assignment" do
    let(:current_user)  { create(:user) }
    let(:course)        { create(:course) }
    let(:assignment)    { create(:published_assignment_with_questions,
                                  course: course, feedback: true) }
    before do
      create(:student_membership, user: current_user, course: course)
      log_in current_user
      visit course_assignment_path course, assignment
    end

    describe "with a multiple choice question" do

      let!(:question) do
        assignment.questions.where("type = 'MultipleChoiceQuestion'").first
      end

      it "should have radio buttons on the page" do
        page.should have_selector("input[type=radio][name='answers[#{question.id}]']")
      end

      it "should have a submit button" do
        page.should have_button("#{question.title}")
      end
    end

  end

  describe "a student taking an assignment with feedback" do
    let(:current_user)  { create(:user) }
    let(:course)        { create(:course) }
    let(:assignment)    { create(:published_assignment_with_questions,
                                  course: course, feedback: true) }
    before do
      create(:student_membership, user: current_user, course: course)
      log_in current_user
      visit course_assignment_path course, assignment
    end

    describe "with a multiple choice question" do

      let!(:question) do
        assignment.questions.where("type = 'MultipleChoiceQuestion'").first
      end

      it "should say that a wrong answer is wrong" do
        choose "answers_#{question.id}_#{question.answers[0]+1}"
        page.find("#question_#{question.id}").click_button("Submit")
        current_path.should eq(course_assignment_path course, assignment)
        page.should have_selector("#question_#{question.id}.incorrect")
      end

      it "should say that a correct answer is correct" do
        choose "answers_#{question.id}_#{question.answers[0]}"
        page.find("#question_#{question.id}").click_button("Submit")
        current_path.should eq(course_assignment_path course, assignment)
        page.should have_selector("#question_#{question.id}.correct")
      end

    end

    describe "with a (multiple choice) question in a group" do
      let!(:group) do
        assignment.questions.where("type = 'QuestionGroup'").first
      end
      let!(:question) do
        group.questions[0]
      end

      it "should say that a wrong answer is wrong" do
        choose "answers_#{question.id}_#{question.answers[0]+1}"
        page.find("#question_#{question.id}").click_button("Submit")
        current_path.should eq(course_assignment_path course, assignment)
        page.should have_selector("#question_#{question.id}.incorrect")
      end

      it "should say that a correct answer is correct" do
        choose "answers_#{question.id}_#{question.answers[0]}"
        page.find("#question_#{question.id}").click_button("Submit")
        current_path.should eq(course_assignment_path course, assignment)
        page.should have_selector("#question_#{question.id}.correct")
      end

    end

  end # End student taking an assignment with feedback

  describe "a student taking an assignment without feedback" do
    let(:current_user)  { create(:user) }
    let(:course)        { create(:course) }
    let(:assignment)    { create(:published_assignment_with_questions,
                                  course: course, feedback: false) }
    before do
      create(:student_membership, user: current_user, course: course)
      log_in current_user
      visit course_assignment_path course, assignment
    end

    describe "with a multiple choice question" do

      let!(:question) do
        assignment.questions.where("type = 'MultipleChoiceQuestion'").first
      end

      it "should say that an unanswered question is unanswered" do
        page.should have_selector("#question_#{question.id}.unanswered")
      end

      it "should say that a wrong answer is answered and not incorrect" do
        choose "answers_#{question.id}_#{question.answers[0]+1}"
        page.find("#question_#{question.id}").click_button("Submit")
        current_path.should eq(course_assignment_path course, assignment)
        page.should have_selector("#question_#{question.id}.answered")
      end

      it "should say that a correct answer is answered and not correct" do
        choose "answers_#{question.id}_#{question.answers[0]}"
        page.find("#question_#{question.id}").click_button("Submit")
        current_path.should eq(course_assignment_path course, assignment)
        page.should have_selector("#question_#{question.id}.answered")
      end

    end

    describe "with a (multiple choice) question in a group" do
      let!(:group) do
        assignment.questions.where("type = 'QuestionGroup'").first
      end
      let!(:question) do
        group.questions[0]
      end

      it "should say that an unanswered question is unanswered" do
        page.should have_selector("#question_#{question.id}.unanswered")
      end

      it "should say that a wrong answer is answered and not incorrect" do
        choose "answers_#{question.id}_#{question.answers[0]+1}"
        page.find("#question_#{question.id}").click_button("Submit")
        current_path.should eq(course_assignment_path course, assignment)
        page.should have_selector("#question_#{question.id}.answered")
      end

      it "should say that a correct answer is answered and not correct" do
        choose "answers_#{question.id}_#{question.answers[0]}"
        page.find("#question_#{question.id}").click_button("Submit")
        current_path.should eq(course_assignment_path course, assignment)
        page.should have_selector("#question_#{question.id}.answered")
      end

    end

  end # End student taking an assignment without feedback

end

# == Schema Information
#
# Table name: assignments
#
#  id             :integer         not null, primary key
#  title          :string(255)
#  release_date   :datetime
#  due_date       :datetime
#  total_points   :decimal(10, 4)  default(0.0)
#  course_id      :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  feedback       :boolean         default(FALSE)
#  resubmit_delay :integer
#

require 'spec_helper'

describe Assignment do
  before { @assignment = create(:assignment) }

  subject { @assignment }

  [:title, :release_date, :due_date, :total_points].each do |attr|
    it { should respond_to(attr) }
  end

  describe "with valid parameters" do
    it { should be_valid }
  end

  describe "with a blank title" do
    before { @assignment.title = "" }
    it { should_not be_valid }
  end

  describe "with no release date" do
    before { @assignment.release_date = nil }
    it { should_not be_valid }
  end

  describe "with no due date" do
    before { @assignment.due_date = nil }
    it { should_not be_valid }
  end
  describe "with due date in the past" do
    before { @assignment.due_date = 1.day.ago}
    it { should_not be_valid }
  end

  describe "with no point value" do
    before { @assignment.total_points = nil }
    it { should_not be_valid }
  end

  describe "with no course" do
    before { @assignment.course = nil }
    it { should_not be_valid }
  end

  describe "with questions" do
    before { @question = create(:question) }
    it "should allow adding a question" do
      expect { @assignment.add_question(@question, 1) }.to change(@assignment.questions, :size).by(1)
    end

    it "should allow adding multiple questions" do
      questions = (1..10).map {create(:question)}
      expect { @assignment.add_questions(questions) }.to change(@assignment.questions, :size).by(10)
    end
    it "should find entry for added questions" do
      @assignment.add_question(@question, 1)
      expect { @assignment.entry_for_question(@question).to exist }
    end
  end

  describe "when assignment is not released" do
    it "should not be published" do
      Timecop.travel(@assignment.release_date - 1.day) { @assignment.published?.should be_false }
    end
  end

  describe "when assignment is released" do
    it "should be published" do
      Timecop.travel(@assignment.release_date + 2.days) { @assignment.published?.should be_true }
    end
  end
  describe "before assignment is due" do
    it "should not be due" do
      @assignment.already_due?.should_not be_true
    end
    it "should give full credit" do
      @assignment.max_points.should eq(@assignment.total_points)
    end
  end
  describe "a day after assignment is due" do
    it "should be due" do
      Timecop.travel(@assignment.due_date + 1.day) { @assignment.already_due?.should be_true }
    end
    it "should give half credit" do
      Timecop.travel(@assignment.due_date + 1.day) { @assignment.max_points.should eq(5.0) }
    end
  end
  describe "a week after assignment is due" do
    it "should be due" do
      Timecop.travel(@assignment.due_date + 7.days) { @assignment.already_due?.should be_true }
    end
    it "should give no credit" do
      Timecop.travel(@assignment.due_date + 7.days) { @assignment.max_points.should eq(0) }
    end
  end

end

# == Schema Information
#
# Table name: question_submissions
#
#  id          :integer         not null, primary key
#  graded      :boolean
#  score       :decimal(10, 4)
#  answer      :text
#  question_id :integer
#  user_id     :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'spec_helper'

describe QuestionSubmission do

  subject { build(:question_submission) }

  [:answer, :question, :user].each do |attr|
    it { should respond_to(attr) }
  end

  it "should serialize its answer" do
    subject.save
    loaded_submission = QuestionSubmission.find(subject.id)
    loaded_submission.answer.should be_a Array
  end

end

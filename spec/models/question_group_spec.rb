# == Schema Information
#
# Table name: questions
#
#  id                  :integer         not null, primary key
#  type                :string(100)
#  text                :text
#  choices             :text
#  answers             :text
#  explanations        :text
#  parent_id           :integer
#  child_index         :integer
#  weight              :decimal(10, 4)  default(1.0)
#  json                :text
#  raw_source          :text
#  raw_source_format   :string(255)
#  javascript_includes :text
#  parameters          :text
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  course_id           :integer
#  title               :string(255)
#

require 'spec_helper'

describe QuestionGroup do

  before { @group = build(:question_group) }

  subject { @group }

  it { should respond_to(:questions) }

  describe "with no questions" do

    its(:questions) { should be_empty }

  end

  describe "with questions" do
    before { @group = create(:question_group_with_questions, 
                            question_count: 5 ) }
    it "should have the right number of questions" do
      @group.questions.length.should eq(5)
    end

    describe "after deleting the question group" do
      let!(:questions) { @group.questions }
      it "should also have deleted its children" do
        expect { @group.destroy }.to change(Question, :count).by(-6)
      end
    end
  end

end

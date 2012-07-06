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

describe Question do

  before { @question = create(:question) }

  subject { @question }


  [:text, :title, :choices, :answers, :explanations, :parent_id, :child_index, 
   :weight, :json, :raw_source, :raw_source_format, :javascript_includes, 
   :parameters].each do |attr|
    it { should respond_to(attr) }
  end

  it { should respond_to(:question_group) }

  its(:explanations) { should be_an_instance_of(Hash) }

  describe "in group" do

    before { @question = create(:question_in_group) }

    describe "after deleting the question" do
      it "should only delete the question, not its group" do
        expect { @question.destroy }.to change(Question, :count).by(-1)
      end
    end

  end

end

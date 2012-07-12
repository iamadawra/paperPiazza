# == Schema Information
#
# Table name: questions
#
#  id                  :integer          not null, primary key
#  type                :string(100)
#  text                :text
#  choices             :text
#  answers             :text
#  explanations        :text
#  parent_id           :integer
#  child_index         :integer
#  weight              :decimal(10, 4)   default(1.0)
#  json                :text
#  raw_source          :text
#  raw_source_format   :string(255)
#  javascript_includes :text
#  parameters          :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  course_id           :integer
#  title               :string(255)
#

require 'spec_helper'

describe MultipleChoiceQuestion do

  before { @question = build(:multiple_choice_question) }
  subject { @question }

  its(:choices) { should be_an_instance_of(Array) }
  its(:answers) { should be_an_instance_of(Array) }

  it "should have strings as choices" do
    @question.choices[0].should be_an_instance_of(String)
  end
  
  it "should have integers as answers" do
    @question.answers[0].should be_an_instance_of(Fixnum)
  end

  it "should mark the correct answer as correct" do
    @question.is_correct?(@question.answers[0]).should be_true
  end

  it "should mark an incorrect answer as incorrect" do
    @question.is_correct?(@question.choices.length).should be_false
  end

  it "should mark gibberish as incorrect" do
    @question.is_correct?("asdsd").should be_false
  end

  it "should mark a nil answer as incorrect" do
    @question.is_correct?(nil).should be_false
  end

  it "should mark a blank answer as incorrect" do
    @question.is_correct?("").should be_false
  end

  describe "when processing form input" do

    it "should turn a string into an integer" do
      @question.preprocess_answer("4").should eq(4)
    end

    it "should turn whitespace into nil" do
      @question.preprocess_answer("").should be_nil
      @question.preprocess_answer("  ").should be_nil
      @question.preprocess_answer("\t  ").should be_nil
    end

    it "should keep nil as nil" do
      @question.preprocess_answer(nil).should be_nil
    end

  end

end

# == Schema Information
#
# Table name: rubric_items
#
#  id          :integer          not null, primary key
#  title       :text
#  description :text
#  weight      :decimal(10, 4)
#  question_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe RubricItem do
  [:title, :description, :weight, :question_id].each do |attr|
    it { should respond_to(attr) }
  end
  before do
    @question = create(:question)
    @rubric_item = build(:rubric_item, :question=>@question)
  end
  subject { @rubric_item }

  it {should be_valid}
  describe "without a title" do
    before {@rubric_item.title = ''}
    it {should_not be_valid}
  end

  describe "without a weight" do
    before {@rubric_item.weight = nil}
    it {should_not be_valid}
  end

  describe "without a question" do
    before {@rubric_item.question = nil}
    it {should_not be_valid}
  end

  describe "without a description" do
    before {@rubric_item.description = ''}
    it {should be_valid}
  end
end

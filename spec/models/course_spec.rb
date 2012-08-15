# == Schema Information
#
# Table name: courses
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  shortname   :string(255)
#  description :text
#  year        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  rating      :integer
#  conference  :string(255)
#  tags        :text
#  author_ids  :text
#

require 'spec_helper'

describe Course do

  before { @course = build(:course) }

  subject { @course }

  [:name, :shortname, :term, :description, :year].each do |attr|
    it { should respond_to(attr) }
  end

  it { should be_valid }

  describe "with a blank name" do
    before { @course.name = "" }
    it { should_not be_valid }
  end

  describe "with a name that's too long" do
    before { @course.name = "a" * 256 }
    it { should_not be_valid }
  end

  describe "with a shortname that's too long" do
    before { @course.shortname = "a" * 256 }
    it { should_not be_valid }
  end

  describe "with a blank shortname" do
    before { @course.shortname = "" }
    it { should be_valid }
  end

  describe "with a nil shortname" do
    before { @course.shortname = nil }
    it { should be_valid }
  end

  describe "with a blank description" do
    before { @course.description = "" }
    it { should_not be_valid }
  end

  describe "with an invalid year" do
    before { @course.year = 1999 }
    it { should_not be_valid }
  end

  describe "with an invalid term" do
    before { @course.term = "Monday" }
    it { should_not be_valid }
  end

  describe "without a year" do
    before { @course.year = nil }
    it { should_not be_valid }
  end

  describe "without a term" do
    before { @course.term = "" }
    it { should_not be_valid }
  end

  describe "with a blank term and a year" do
    before { @course.term = "" }
    it { should_not be_valid }
  end

  describe "with a blank term and no year" do
    before { @course.term = @course.year = "" }
    it { should be_valid }
  end

  describe "with the current year" do
    before { @course.year = Time.now.year }
    it { should be_valid }
  end

  describe "with a valid term" do
    before { @course.term = "Fall" }
    it { should be_valid }
  end

  describe "with an instructor" do
    let(:membership) { build(:instructor_membership, course: @course) }
    before { @course.save; membership.save }
    its(:instructors) { should_not be_empty }

    describe "with no students" do
      its(:students) { should be_empty }
    end
    describe "with students" do
      let(:membership) { build(:student_membership, course: @course) }
      before { @course.save; membership.save }
      its(:students) { should_not be_empty }
    end
    describe "with no TAs" do
      its(:tas) { should be_empty }
    end
    describe "with TAs" do
      let(:membership) { build(:ta_membership, course: @course) }
      before { @course.save; membership.save }
      its(:tas) { should_not be_empty }
    end
  end

  describe "without an instructor" do
    its(:instructors) {should be_empty}
  end
  describe "with no users" do
    let!(:user) {create(:user)}
    its(:instructors) {should be_empty}
    its(:tas) {should be_empty}
    its(:students) {should be_empty}
    its(:users) {should be_empty}
    it "should not have any members" do
      @course.has_instructor?(user).should be_false
      @course.has_ta?(user).should be_false
      @course.has_student?(user).should be_false
    end
  end
end

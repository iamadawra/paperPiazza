# == Schema Information
#
# Table name: course_memberships
#
#  id         :integer          not null, primary key
#  course_id  :integer          not null
#  user_id    :integer          not null
#  role       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe CourseMembership do

  subject { @membership }

  describe "any membership" do
    before { @membership = build(:student_membership) }
    [:user, :course, :role].each do |attr|
      it { should respond_to(attr) }
    end
    it { should be_valid }

    describe "with no course" do 
      before { @membership.course = nil }
      it { should_not be_valid }
    end

    describe "with no user" do 
      before { @membership.user = nil }
      it { should_not be_valid }
    end

    describe "with no role" do 
      before { @membership.role = nil }
      it { should_not be_valid }
    end

    describe "with an invalid role" do 
      before { @membership.role = -1 }
      it { should_not be_valid }
    end

    describe "with a previous existing identical memberhsip" do 
      before do
        new_membership = @membership.dup
        new_membership.save
      end
      it { should_not be_valid }
    end

  end

  describe "a student membership" do
    before { @membership = build(:student_membership) }
    it { should be_valid }
    its(:role) { should eq(CourseMembership.student_role) }
  end

  describe "an instructor membership" do
    before { @membership = build(:instructor_membership) }
    it { should be_valid }
    its(:role) { should eq(CourseMembership.instructor_role) }
  end

  describe "a ta membership" do
    before { @membership = build(:ta_membership) }
    it { should be_valid }
    its(:role) { should eq(CourseMembership.ta_role) }
  end

end

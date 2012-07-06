# == Schema Information
#
# Table name: assignment_entries
#
#  id             :integer         not null, primary key
#  number         :integer
#  assignment_id  :integer
#  question_id    :integer
#  points         :decimal(10, 4)  default(0.0)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  resubmit_delay :integer
#

require 'spec_helper'

describe AssignmentEntry do
  it "validates resubmit delay numericality when it is present" do
    AssignmentEntry.new(resubmit_delay: 42).should be_valid
    AssignmentEntry.new(resubmit_delay: "foo").should_not be_valid
  end

  it "does not validate resubmit delay when it is absent" do
    AssignmentEntry.new.should be_valid
  end
end

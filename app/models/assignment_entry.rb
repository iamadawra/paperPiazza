# == Schema Information
#
# Table name: assignment_entries
#
#  id             :integer          not null, primary key
#  number         :integer
#  assignment_id  :integer
#  question_id    :integer
#  points         :decimal(10, 4)   default(0.0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  resubmit_delay :integer
#

class AssignmentEntry < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :question

  attr_accessible :resubmit_delay, :question_id

  validates :resubmit_delay, numericality: true, if: -> { resubmit_delay.present? }
end

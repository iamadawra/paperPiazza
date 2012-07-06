# == Schema Information
#
# Table name: course_memberships
#
#  id         :integer         not null, primary key
#  course_id  :integer         not null
#  user_id    :integer         not null
#  role       :integer(1)      not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class CourseMembership < ActiveRecord::Base

  # attr_accessible is okay here as long as we never have any forms
  # accepting input for CourseMemberships and nothing
  # accepts_nested_attributes for CourseMemberships.
  
  attr_accessible :course, :user, :role

  ROLE_STUDENT      = 0
  ROLE_INSTRUCTOR   = 1
  ROLE_TA           = 2

  ROLES = [ ROLE_STUDENT, ROLE_INSTRUCTOR, ROLE_TA ]

  belongs_to :user
  belongs_to :course

  validates_uniqueness_of :user_id, :scope => [:course_id]
  validates_inclusion_of  :role, :in => ROLES

  validates_presence_of :user_id
  validates_presence_of :course_id
  validates_presence_of :role

  def self.student_role
    ROLE_STUDENT
  end

  def self.instructor_role
    ROLE_INSTRUCTOR
  end

  def self.ta_role
    ROLE_TA
  end

end


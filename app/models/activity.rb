# == Schema Information
#
# Table name: activities
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  course_id  :integer
#  time       :datetime
#  action     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Activity < ActiveRecord::Base
  
  attr_accessible :id, :user_id, :course_id, :action

end

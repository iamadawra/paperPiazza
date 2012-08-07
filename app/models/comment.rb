# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  course_id  :integer
#  body       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Comment < ActiveRecord::Base
   belongs_to :user
   belongs_to :course

   attr_accessible :body

   validates :user_id, :presence => true
   validates :course_id, :presence => true
   validates :body, :presence => true, :length => { :maximum => 50000 }     # spam protection

   default_scope :order => 'comments.created_at asc'
end

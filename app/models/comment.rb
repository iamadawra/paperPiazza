# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_id   :integer          default(0)
#  commentable_type :string(255)      default("")
#  title            :string(255)      default("")
#  body             :text             default("")
#  subject          :string(255)      default("")
#  user_id          :integer          default(0), not null
#  parent_id        :integer
#  lft              :integer
#  rgt              :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
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

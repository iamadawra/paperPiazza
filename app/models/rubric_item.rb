# == Schema Information
#
# Table name: rubric_items
#
#  id          :integer         not null, primary key
#  title       :text
#  description :text
#  weight      :decimal(10, 4)
#  question_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class RubricItem < ActiveRecord::Base
  belongs_to :question

  validates :weight, :numericality => true
  validates :title, :presence => true
  validates :question_id, :presence => true

  attr_accessible :title, :description, :weight, :question_id
end

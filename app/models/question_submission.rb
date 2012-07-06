# == Schema Information
#
# Table name: question_submissions
#
#  id          :integer         not null, primary key
#  graded      :boolean
#  score       :decimal(10, 4)
#  answer      :text
#  question_id :integer
#  user_id     :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class QuestionSubmission < ActiveRecord::Base

  serialize :answer

  belongs_to :question
  belongs_to :user

  def grade
    score = self.question.grade(self.answer)
    if score
      self.score = score
      self.graded = true
    end
  end

  def grade!
    self.grade
    self.save if self.score
  end

end

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
# 4/5 EDL -
# Nested under Course specifically to provide authorization against the Course.
class QuestionSubmissionsController < ApplicationController

  def create

    if params[:assignment_id]
      assignment = Assignment.find params[:assignment_id]
    end
    question   = Question.find params[:question_id]
    answer     = params[:answers].try(:[], question.id.to_s)

    submission = question.build_submission(current_user, answer)
    submission.grade!

    respond_to do |format|
      format.html do
        unless request.xhr?
          redirect_to request.env["HTTP_REFERER"] + params[:anchor]
        else
          @question = question
          @answer   = question.preprocess_answer(answer)
          render "questions/in_lecture_response", :layout => false
        end
      end
    end

  end

end

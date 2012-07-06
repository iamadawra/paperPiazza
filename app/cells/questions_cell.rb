class QuestionsCell < Cell::Rails

  helper :application, :questions
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  build do |args|
    (args[:question].class.name + "sCell").constantize
  end

  def show(args)
    @user             = args[:user] || nil
    @show_submissions = args[:show_submissions] || false
    @show_discussion  = true
    @question         = args[:question]
    @assignment       = args[:assignment]
    @index            = args[:index]
    @prefix           = args[:prefix] || nil
    @feedback         = args[:feedback] || false
    @show_points      = args[:show_points] || false
    @embedded         = args[:embedded] || false

    @submission     = @question.submissions.last_submission_for_user(@user)

    @answer         = shown_answer
    @feedback_class = feedback_class

    @full_title     = full_title(@index, @prefix)
    @header         = header

    if @assignment and @question
      @form_url       = assignment_question_submissions_path(@assignment.id, @question.id)
    end

    render
  end

  def form(args)
    @user             = args[:user] || nil
    @show_submissions = args[:show_submissions] || false
    @show_discussion  = true
    @question         = args[:question]
    @assignment       = args[:assignment]
    @index            = args[:index]
    @prefix           = args[:prefix] || nil
    @feedback         = args[:feedback] || false
    @show_points      = args[:show_points] || false
    @embedded         = args[:embedded] || false

    @submission     = @question.submissions.last_submission_for_user(@user)

    @answer         = shown_answer
    @feedback_class = feedback_class

    @answer_name    = answer_name
    @full_title     = full_title(@index, @prefix)
    @header         = header
    @button_text    = button_text

    # TODO Fix this..
    if @assignment
      @form_url = assignment_question_submissions_path(@assignment, @question)
    else
      @form_url = course_question_submissions_path(@question.course, @question)
    end

    render
  end

  def navigation_link(args)
    @question   = args[:question]
    @assignment = args[:assignment]
    @user       = args[:user] || nil
    @index      = args[:index]
    @prefix     = args[:prefix] || "Question"
    @anchor     = args[:anchor]
    @feedback   = args[:feedback] || false

    @submission     = @question.submissions.last_submission_for_user(@user)
    @answer         = shown_answer
    @feedback_class = feedback_class
    @form_url       = assignment_question_submissions_path(@assignment.id, @question.id)
    render
  end

  def submissions
    render if @user and @show_submissions
  end

  def discussion
    render if @show_discussion
  end

  def show_choices
    render
  end

  def form_choices
    render
  end

  def shown_answer
    return @submission.answer if @submission
    return formatted_correct_answer if @question.answer_visible_by?(@user)
    return nil
  end

  def feedback_class
    return "" if @embedded
    return "unanswered" unless @answer
    return "answered" unless @feedback
    return @question.is_correct?(@answer) ? "correct" : "incorrect"
  end

  def formatted_correct_answer
    @question.answers
  end

  def full_title(index, prefix)
    text = ""
    if index
      text += "#{prefix} #{index}"
    end
    if @question.title and @question.title != ""
      text += ": " if text != ""
      text += @question.title
    end
    return text
  end

  def button_text
    return @embedded ? "Submit" : "Submit #{@full_title}" 
  end

  def header
    return @full_title unless @show_points
    if @full_title != ""
      @full_title + " (#{points})"
    else
      points
    end
  end

  def header_anchor
    render
  end

  def answer_name
    "answers[#{@question.id}]"
  end

  def points
    pluralize(number_with_precision(@question.weight, precision: 2, strip_insignificant_zeros: true), "point")
  end
end

class ChoiceBasedQuestionsCell < QuestionsCell
end

class MultipleChoiceQuestionsCell < ChoiceBasedQuestionsCell
  def formatted_correct_answer
    @question.answers[0]
  end
end

class SelectAllQuestionsCell < ChoiceBasedQuestionsCell
end

class EssayQuestionsCell < QuestionsCell
end

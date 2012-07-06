# == Schema Information
#
# Table name: questions
#
#  id                  :integer         not null, primary key
#  type                :string(100)
#  text                :text
#  choices             :text
#  answers             :text
#  explanations        :text
#  parent_id           :integer
#  child_index         :integer
#  weight              :decimal(10, 4)  default(1.0)
#  json                :text
#  raw_source          :text
#  raw_source_format   :string(255)
#  javascript_includes :text
#  parameters          :text
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  course_id           :integer
#  title               :string(255)
#

require 'pandoc-ruby'

class Question < ActiveRecord::Base

  attr_accessible :title, :text, :choices, :answers, :explanations, 
                  :child_index, :weight, :json, :raw_source, 
                  :raw_source_format, :javascript_includes, :parameters

  serialize :choices
  serialize :answers
  serialize :explanations

  belongs_to :course

  belongs_to :question_group, :foreign_key => :parent_id
  has_many :assignment_entries, :dependent => :delete_all
  has_many :assignments, :through => :assignment_entries
  has_many :rubric_items

  has_many :in_lecture_questions

  has_many :submissions, :class_name => "QuestionSubmission", :dependent => :delete_all do
    def by_user(user)
      where(:user_id => user)
    end

    def last_submission_for_user(user)
      by_user(user).order("question_submissions.created_at DESC").first
    end

    def most_recent_time_for_user(user)
      time = by_user(user).maximum("question_submissions.created_at")
      return time.try(:in_time_zone, 'Pacific Time (US & Canada)') # TODO localize
    end

    # TODO see what is needed here..
    #def order_per_user(ordering)
    #  where("assignment_submissions.id = (select id from assignment_submissions as alt where alt.user_id = assignment_submissions.user_id and alt.assignment_id = ? ORDER BY #{ordering} LIMIT 1)", proxy_association.owner.id)
    #end

    #def most_recent_per_user
    #  order_per_user('created_at DESC').recent
    #end

    #def highest_per_user
    #  order_per_user('points DESC, created_at ASC')
    #end

    #def max_score_for_user(user)
    #  where(:user_id => user).maximum("assignment_submissions.points")
    #end
  end

  scope :published, where('')

  def published?
    true
  end

  def grade(answer)
    return self.is_correct?(answer) ? self.weight : 0
  end

  def answer_visible_by?(user)
    return false if user.nil?
    return false unless self.course
    return self.course.has_instructor?(user) || self.course.has_ta?(user)
  end

  def self.from_editor_data(data, params={})
  
    # Converts string keys to symbols
    data = data.each_with_object({}){|(k,v), h| h[k.to_sym] = v}

    type = data[:type]
    #TODO: This shouldn't hardcode question types and should return some sort of error if it wasn't saved?
    case type
      when "QuestionGroup", "SelectAllQuestion", "MultipleChoiceQuestion", "EssayQuestion"#, "CustomHTMLChooseAll", "CustomHTMLMultipleChoice"
        question        = type.constantize.new
        question.course = params[:course] if params[:course]
        question.json   = data.to_json
        question.text   = process_text(data[:description])
        question.title  = strip_paragraph(process_text(data[:title]))
        question.weight = data[:score]
        if data[:explanations] and data[:explanations].strip != ""
          question.explanations     = process_text(data[:explanations])
        end
      else
        return nil
    end

    if question.process_editor_data(data) and question.save
      return question
    else
      return nil
    end
  end

  def build_submission(user, answer)
    submission        = self.submissions.build
    submission.answer = self.preprocess_answer(answer)
    submission.user   = user
    return submission
  end

  protected

    def self.process_text(text)
      return PandocRuby.convert(text, {:from => :markdown, :to => :html, :mathjax => nil})
    end

    def self.strip_paragraph(choice)
      return choice.gsub(/^<p>/, "").gsub("</p>","")
    end

end

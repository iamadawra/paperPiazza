# == Schema Information
#
# Table name: assignments
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  release_date   :datetime
#  due_date       :datetime
#  total_points   :decimal(10, 4)   default(0.0)
#  course_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  feedback       :boolean          default(FALSE)
#  resubmit_delay :integer
#

class Assignment < ActiveRecord::Base
  attr_accessible :title, :release_date, :release_date_string, :due_date, :due_date_string, :total_points, :feedback, :resubmit_delay, :entries_attributes

  belongs_to :course

  has_many :entries, :class_name => "AssignmentEntry",
                     :dependent => :delete_all,
                     :order => :number
  accepts_nested_attributes_for :entries

  has_many :questions, :through => :entries,
                       :order => 'assignment_entries.number'

  validates_presence_of :release_date
  validates_presence_of :due_date
  validates_presence_of :course_id

  validates :title, presence: true, length: { maximum: 255 }
  validates :total_points, :numericality => { :greater_than_or_equal_to => 0.0 }
  validates :resubmit_delay,
    :numericality => { :greater_than_or_equal_to => 0 },
    :if => -> { resubmit_delay.present? }

  validate :due_date_in_future

  default_scope order('due_date')

  scope :published, lambda { where('release_date <= ?', Time.zone.now) }

  def published?
    self.release_date <= Time.zone.now
  end

  def entry_for_question(question)
    return AssignmentEntry.where(:assignment_id => self, :question_id => question).first
  end

  def add_question(question, points)
    ae = AssignmentEntry.new
    ae.assignment   = self
    ae.question     = question
    ae.number       = self.questions.count
    ae.points       = points
    ae.save
    self.total_points += points
    self.save
  end

  def add_questions(question_ids)
    question_ids.each do |id|
      question = Question.find_by_id(id)
      return false if not question
      self.add_question question, 1
    end
    return true
  end

  def already_due?
    return self.due_date < Time.zone.now
  end

  def late_credit
    days_late = (Time.zone.now - self.due_date) / (60 * 60 * 24)
    if days_late > 7
      late_credit = 0
    elsif days_late > 1
      late_credit = 0.5
    elsif days_late > 0
      late_credit = 0.8
    else
      late_credit = 1
    end
  end

  def max_points
    self.total_points * self.late_credit
  end

  def due_date_in_future
    if due_date and Time.zone.now > due_date
      errors.add(:due_date, 'must be in the future')
    end
  end

  # TODO test these
  def release_date_date
    self.release_date.try(:to_s, :form_date)
  end

  def release_date_time
    self.release_date.try(:to_s, :form_time)
  end

  def release_date_string=(date_string)
    self.release_date = Timeliness.parse(date_string.strip)
  end

  def due_date_date
    self.due_date.try(:to_s, :form_date)
  end

  def due_date_time
    self.due_date.try(:to_s, :form_time)
  end

  def due_date_string=(date_string)
    self.due_date = Timeliness.parse(date_string.strip)
  end

  # FIXME broken for qgs.
  def score(user)
    return nil if (questions.map { |q| q.submissions.by_user(user).length } << 0).max == 0
    score = 0
    questions.each do |question|
      score = score + (question.submissions.by_user(user).map { |sub| sub.score } << 0.0).max
    end
    return score * late_credit
  end
end

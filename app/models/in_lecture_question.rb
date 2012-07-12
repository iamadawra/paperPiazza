# == Schema Information
#
# Table name: in_lecture_questions
#
#  id          :integer          not null, primary key
#  lecture_id  :integer          not null
#  question_id :integer          not null
#  hours       :integer          default(0), not null
#  minutes     :integer          default(0), not null
#  seconds     :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class InLectureQuestion < ActiveRecord::Base

  attr_accessible :hours, :minutes, :seconds, :question_id

  belongs_to :question
  belongs_to :lecture, :inverse_of => :in_lecture_questions

  validates_presence_of :lecture, :question
  
  validates_presence_of :hours, :minutes, :seconds
  validates_numericality_of :minutes, :seconds, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 59
  validates_numericality_of :hours, :greater_than_or_equal_to => 0

  validate :time_within_video_range, :unless => "lecture.nil? or hours.nil? or minutes.nil? or seconds.nil?"

  def time_in_seconds
    return hours * 3600 + minutes * 60 + seconds 
  end

  protected

  def time_within_video_range
    return unless self.lecture.video_duration

    if self.time_in_seconds > self.lecture.video_duration_in_seconds or self.time_in_seconds < 0
      video_hours   = self.lecture.video_duration_hours
      video_minutes = self.lecture.video_duration_minutes
      video_seconds = self.lecture.video_duration_seconds
      msg = "^In-video assignment time must be less than your video's duration (%02d:%02d:%02d)." % [video_hours, video_minutes, video_seconds]
      errors.add(:time, msg)
    end
  end

end

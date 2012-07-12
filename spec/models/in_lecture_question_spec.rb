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

require 'spec_helper'

describe InLectureQuestion do

  let(:in_lecture_question) { build(:in_lecture_question) }

  subject { in_lecture_question }

  [:lecture, :question, :hours, :minutes, :seconds].each do |attr|
    it { should respond_to(attr) }
  end

  it { should respond_to(:time_in_seconds) }

  it { should be_valid }

  describe "with a nil hours" do
    before { in_lecture_question.hours = nil }
    it { should_not be_valid }
  end

  describe "with a nil minutes" do
    before { in_lecture_question.minutes = nil }
    it { should_not be_valid }
  end

  describe "with a nil seconds" do
    before { in_lecture_question.seconds = nil }
    it { should_not be_valid }
  end

  describe "with a nil question" do
    before { in_lecture_question.question = nil }
    it { should_not be_valid }
  end

  describe "with a nil lecture" do
    before { in_lecture_question.lecture = nil }
    it { should_not be_valid }
  end

  describe "with a negative time" do
    before do
      in_lecture_question.hours   = 0
      in_lecture_question.minutes = 0
      in_lecture_question.seconds = -1
    end

    it { should_not be_valid }
  end

  describe "with a time greater than the video's duration" do
    before do
      in_lecture_question.lecture.video_duration = 8923
      video_hours   = in_lecture_question.lecture.video_duration_hours
      video_minutes = in_lecture_question.lecture.video_duration_minutes
      video_seconds = in_lecture_question.lecture.video_duration_seconds

      in_lecture_question.hours    = video_hours
      in_lecture_question.minutes  = video_minutes
      in_lecture_question.seconds  = video_seconds + 1
    end

    it { should_not be_valid }
  end

  describe "with a time within the video's duration" do

    before do
      in_lecture_question.lecture.video_duration = 8923
      video_hours   = in_lecture_question.lecture.video_duration_hours
      video_minutes = in_lecture_question.lecture.video_duration_minutes
      video_seconds = in_lecture_question.lecture.video_duration_seconds

      in_lecture_question.hours    = video_hours
      in_lecture_question.minutes  = video_minutes
      in_lecture_question.seconds  = video_seconds - 1
    end

    it "should report the time in seconds" do
      actual_seconds = in_lecture_question.hours * 3600 + in_lecture_question.minutes * 60 + in_lecture_question.seconds
      in_lecture_question.time_in_seconds.should eq(actual_seconds)
    end

    it { should be_valid }

  end

end

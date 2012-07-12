# == Schema Information
#
# Table name: lectures
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  video_url      :string(255)
#  slides_url     :string(255)
#  number         :integer
#  release_date   :datetime
#  course_id      :integer
#  video_duration :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe Lecture do
  before { @lecture = build(:lecture) }

  subject { @lecture }
  [:title, :release_date, :video_url, :number, :course_id, :video_duration].each do |attr|
    it { should respond_to(attr) }
  end

  describe "with valid parameters" do
    it { should be_valid }
  end

  describe "with a blank title" do
    before { @lecture.title = "" }
    it { should_not be_valid }
  end

  describe "with no release date" do
    before { @lecture.release_date = nil }
    it { should_not be_valid }
  end

  describe "before release date" do
    it "should not be published" do
      Timecop.travel(subject.release_date - 1.day) { subject.published?.should be_false }
    end
  end

  describe "after release date" do
    it "should be published" do
      Timecop.travel(subject.release_date + 1.day) { subject.published?.should be_true }
    end
  end
  describe "with no video url" do
    before { @lecture.video_url = nil }
    it { should_not be_valid }
  end
  describe "with an invalid video URL" do
    before { @lecture.video_url = 'http://www.google.com' }
    it { should_not be_valid }
  end

  describe "with a nonexistent video URL" do
    before { @lecture.video_url = 'http://www.youtube.com/watch?v=T7-VjEAAASA' }
    it { should_not be_valid }
  end
end

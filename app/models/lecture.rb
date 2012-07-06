# == Schema Information
#
# Table name: lectures
#
#  id             :integer         not null, primary key
#  title          :string(255)
#  video_url      :string(255)
#  slides_url     :string(255)
#  number         :integer
#  release_date   :datetime
#  course_id      :integer
#  video_duration :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

require 'net/http'
class Lecture < ActiveRecord::Base

  attr_accessible :title, :video_url, :slides_url, :number, :release_date, :release_date_string, :in_lecture_questions_attributes

  belongs_to :course

  has_one :comment_thread, :class_name => "CommentThread", :as => :thread_owner, :dependent => :destroy

  # TODO ensure validation of release date is done properly
  validates_presence_of :title, :video_url, :release_date
  validate :video_url_has_youtube_id, :youtube_video_exists, :if => "video_url?"

  has_many :in_lecture_questions, :inverse_of => :lecture do
    def view_info
      all.map { |x| {question_id: x.question_id, time: x.time_in_seconds} }
    end
  end
  
  has_many :questions, :through => :in_lecture_questions
  accepts_nested_attributes_for :in_lecture_questions, :allow_destroy => true, :reject_if => :all_blank

  default_scope order('release_date')
  scope :published, lambda { where('release_date <= ?', Time.zone.now) }

  YOUTUBE_WATCH_URL_REGEX = /^.*youtube.com\/.*watch\?v=([^&]+).*/
  YOUTUBE_EMBED_URL_REGEX = /^.*youtube.com\/embed\/([^&]+).*/

  before_validation do
    self.get_video_duration if attribute_present?("video_url")
  end

  def published?
    self.release_date <= Time.zone.now
  end

  def youtube_id
    if self.video_url?
      if video_url =~ YOUTUBE_WATCH_URL_REGEX
      elsif video_url =~ YOUTUBE_EMBED_URL_REGEX
      end
      return $1
    end
    return nil
  end

  def get_video_duration
    if self.youtube_id
      path = "/feeds/api/videos/#{self.youtube_id}?v=2&alt=jsonc"
      request = Net::HTTP::Get.new(path)
      response = Net::HTTP.start("gdata.youtube.com") { |http|
        http.open_timeout = http.read_timeout = 60
        http.request(request)
      }
      response = ActiveSupport::JSON.decode(response.body)
      if response["data"]
        self.video_duration = response["data"]["duration"]
      end
    end
  end

  # TODO test these
  def release_date_date
    return self.release_date.to_s(:form_date) if self.release_date
    return Time.zone.now.tomorrow.to_s(:form_date)
  end

  def release_date_time
    return self.release_date.to_s(:form_time) if self.release_date
    return Time.local(2012, "Jan", 1, 0).to_s(:form_time)
  end

  def release_date_string=(date_string)
    self.release_date = Timeliness.parse(date_string.strip)
  end

  def video_duration_hours
    return nil unless self.video_duration
    return self.video_duration / 3600
  end

  def video_duration_minutes
    return nil unless self.video_duration
    return (self.video_duration % 3600) / 60
  end

  def video_duration_seconds
    return nil unless self.video_duration
    return self.video_duration % 60
  end

  def video_duration_in_seconds
    return self.video_duration
  end

  protected

  ### Validations ###
  def video_url_has_youtube_id
    unless self.youtube_id
      errors.add(:video_url, "does not seem to be a valid YouTube video link.")
    end
  end

  def youtube_video_exists
    if self.youtube_id and not self.video_duration?
      errors.add(:video_url, "contains a nonexistent YouTube video id: #{self.youtube_id}.")
    end
  end

end

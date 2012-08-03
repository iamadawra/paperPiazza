# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  password_digest        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  remember_token         :string(255)
#  perishable_token       :string(255)
#  password_reset_sent_at :datetime
#  admin                  :boolean          default(FALSE), not null
#  owner_id               :integer
#  topics_count           :integer          default(0)
#  posts_count            :integer          default(0)
#

require 'custom_has_secure_password'

class User < ActiveRecord::Base

  # Doesn't perform validation
  custom_has_secure_password

  attr_accessible :name, :email, :password, :password_confirmation

  ajaxful_rater

  validates :name, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, 
                                    uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 7 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :password_digest, presence: {message: "^Password can't be blank"}
  validates_confirmation_of :password

  before_create { create_token(:remember_token) }

  has_many :course_memberships
  has_many :courses, :through => :course_memberships
  has_many :topics, :dependent => :destroy
  has_many :posts, :dependent => :destroy

  has_many :question_submissions

  def send_password_reset
    create_token(:perishable_token)
    # Use Time.zone to allow for user customized time zones later.
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def is_admin?
    self.admin
  end

  private

    def create_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end

end

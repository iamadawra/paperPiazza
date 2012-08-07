# == Schema Information
#
# Table name: courses
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  shortname   :string(255)
#  description :text
#  year        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  rating      :integer
#  conference  :string(255)
#

require 'has_roles'

class Course < ActiveRecord::Base

  has_many :comments, :dependent => :destroy
  
  attr_accessible :name, :shortname, :description, :year, :scopetest, :rating, :conference, :title, :teaser, :body, :version, :changelog

  ajaxful_rateable :stars => 10

  TERMS = ['Spring', 'Summer', 'Fall', 'Winter']

  validates :name, presence: true, length: {maximum: 255}
  validates :shortname, length: {maximum: 255}

  validates_presence_of :description
  validates_presence_of :conference
  validates_presence_of :year

  validates_numericality_of :year, 
                            :only_integer => true, 
                            :allow_blank => true

  validates_inclusion_of :term, :in => TERMS, :allow_blank  => true
  validates_inclusion_of :year, 
                         :in => -> {(Time.now.year-50)..(Time.now.year)}.call,
                         :allow_blank => true
  has_many :memberships, :class_name => "CourseMembership", :dependent => :delete_all do
    def for_user(user)
      return nil unless user
      where("user_id = ?", user.id).first
    end
  end

  # These are defined in lib/modules/has_roles. Makes it nice since we can
  # just define a method once and it's usable by all roles.
  has_roles CourseMembership, :memberships
  add_role(:instructor)
  add_role(:ta)
  add_role(:student)

  has_many :users, :through => :memberships

  has_many :lectures

  has_many :assignments
  has_many :questions


  def has_member?(user)
    !!self.memberships.for_user(user)
  end

  def full_term
    self.term + " " + self.year.to_s if self.term
  end

  def to_short_s
    s = self.shortname.blank? ? self.name : self.shortname
    if full_term and not full_term.blank?
      s += ", " + full_term
    end
    s
  end

  def to_s
    if self.term and self.year
      self.name + ', ' + self.full_term
    else
      self.name
    end
  end
  
  def self.search(search)
    if search
      where(['name LIKE ? OR description LIKE? OR year LIKE? OR conference LIKE? OR shortname LIKE?', ["%#{search}%"]*5].flatten)
    else
      scoped
    end
  end

end

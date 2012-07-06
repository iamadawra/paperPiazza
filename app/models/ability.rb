class Ability
  include CanCan::Ability

  def initialize(user)

    @user = user || User.new # guest user (not logged in)
    if @user.is_admin?
      can :manage, :all
    else
      user_permissions
      course_permissions
    end
  end
  
  def self.switch
    if course.has_instructor?(@user) 
	  student_permissions(course)
	else
	  intructor_permissions(course)
    end
  end

  def user_permissions
    can :manage, User, id: @user.id
  end

  def course_permissions

    can :read, Course, [] do |course|
      if course.has_member?(@user)
        can :manage, CourseMembership,  user_id: @user.id, 
          course_id: course.id
        instructor_permissions(course) if course.has_instructor?(@user)
        ta_permissions(course)         if course.has_ta?(@user)
        student_permissions(course)    if course.has_student?(@user)
      else
        # They can join a course if they're a member of the site.
        can :create, CourseMembership, course_id: course.id, user_id: @user.id
      end

      # Anyone can read courses
      true
    end

    can :update, Course do |course|
      if course.has_instructor?(@user)
        instructor_permissions(course)
        true
      end
    end

    can :create, Course if @user.persisted?

  end

  def instructor_permissions(course)
    can :manage, Assignment, course_id: course.id
    can :manage, Lecture,    ['course_id = ?', course.id] do |lecture|
      can :manage, InLectureQuestion, lecture_id: lecture.id
      lecture.course_id == course.id
    end
    can :manage, Question,   ['course_id = ?', course.id] do |question|
      can :manage, QuestionSubmission, question_id: question.id
      question.course_id == course.id
    end
  end

  def ta_permissions(course)
    instructor_permissions(course)
  end

  def student_permissions(course)
    can :read, Assignment, Assignment.published.where(course_id: course.id) do |assignment|
      assignment.published? and assignment.course_id == course.id
    end

    can :read, Lecture, Lecture.published.where(course_id: course.id) do |lecture|
      lecture.published? and lecture.course_id == course.id
    end

    can :read, Question, Question.published.where(course_id: course.id) do |question|
      if question.course_id == course.id and question.published?
        can :create, QuestionSubmission, question_id: question.id, 
          user_id: @user.id
        can :read,   QuestionSubmission, question_id: question.id, 
          user_id: @user.id
        true
      else
        false
      end
    end
  end
end


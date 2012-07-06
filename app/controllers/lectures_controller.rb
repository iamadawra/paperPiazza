class LecturesController < ApplicationController

  before_filter :filter_params, :only => [:create, :update]

  load_and_authorize_resource :course
  load_and_authorize_resource :lecture, :through => :course, :except => [:create, :update]

  def new
    @questions = Question.accessible_by(current_ability, :read).where('parent_id is NULL')
  end

  def edit
    @questions = Question.accessible_by(current_ability, :read).where('parent_id is NULL')
  end

  def update
    # This action does not automatically authorize resources.
    logger.debug params[:lecture]
    @lecture = @course.lectures.find(params[:id])
    authorize! :update, @lecture

    # Need to authorize that the user can use each question.
    # TODO make this not terribly inefficient
    in_lecture_attrs = params[:lecture][:in_lecture_questions_attributes]
    if in_lecture_attrs
      in_lecture_attrs.each do |i, attrs|
        question = Question.find(attrs[:question_id])
        authorize! :manage, question
      end
    end

    @lecture.update_attributes(params[:lecture])

    if @lecture.save
      flash[:success] = "Your lecture '#{@lecture.title}' was successfully saved."
      redirect_to [@course, @lecture]
    else
      @questions = Question.accessible_by(current_ability, :read).where('parent_id is NULL')
      render :new
    end
  end

  def create
    # This action does not automatically authorize resources.
    @lecture = @course.lectures.build(params[:lecture])
    authorize! :create, @lecture

    # Need to authorize that the user can use each question.
    # TODO make this not terribly inefficient
    in_lecture_attrs = params[:lecture][:in_lecture_questions_attributes]
    if in_lecture_attrs
      in_lecture_attrs.each do |i, attrs|
        question = Question.find(attrs[:question_id])
        authorize! :manage, question
      end
    end

    if @lecture.save
      flash[:success] = "Your lecture '#{@lecture.title}' was successfully created."
      redirect_to [@course, @lecture]
    else
      @questions = Question.accessible_by(current_ability, :read).where('parent_id is NULL')
      render :new
    end
  end

  def show
  end

  def index
  end

  def destroy
    @lecture.delete
    redirect_to course_lectures_path
  end
  private
    def filter_params
      params[:lecture][:release_date_string] = params[:lecture][:release_date_date].strip + " " + params[:lecture][:release_date_time].strip
      params[:lecture].delete :release_date_time
      params[:lecture].delete :release_date_date
    end

end

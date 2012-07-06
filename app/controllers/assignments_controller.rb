include Rack::Utils

class AssignmentsController < ApplicationController

  before_filter :filter_params, :only => :create

  load_and_authorize_resource :course
  load_and_authorize_resource :assignment, :through => :course

  def new
    @questions = @course.questions.where("parent_id is NULL")
    @available_questions = @questions.all - @assignment.entries.map(&:question)
    @question_ids = []
  end

  def create
    if @assignment.save
      @assignment.total_points = @assignment.questions.map{ |q| q.weight }.reduce(0, :+)
      @assignment.save
      redirect_to course_assignment_url @course, @assignment
    else
      @questions = @course.questions.where("parent_id is NULL")
      @question_ids = (parse_nested_query(params[:question_ids])["question_ids"] || []).map {|x| x.to_i}
      @available_questions = @questions.all - @assignment.entries.map(&:question)
      render :new
    end
  end

  def update
  end

  def index
  end

  def show
    if not @assignment
      flash[:error] = 'No assignment found'
      redirect_to course_assignments_path @course
    end
  end

  def destroy
    @assignment.delete
    redirect_to course_assignments_path @course
  end

  private

    def filter_params
      params[:question_ids] = params[:assignment][:question_ids]
      params[:assignment] = params[:assignment].reject {|k| k=='question_ids' }
      params[:assignment][:release_date_string] = params[:assignment][:release_date_date].strip + " " + params[:assignment][:release_date_time].strip
      params[:assignment].delete :release_date_time
      params[:assignment].delete :release_date_date
      params[:assignment][:due_date_string] = params[:assignment][:due_date_date].strip + " " + params[:assignment][:due_date_time].strip
      params[:assignment].delete :due_date_time
      params[:assignment].delete :due_date_date
    end

end

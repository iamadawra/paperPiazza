class RubricItemsController < ApplicationController
  before_filter :load_question
  def new
    @rubric_item = RubricItem.new
  end

  def create
    @rubric_item = RubricItem.new(params[:rubric_item])
    if @rubric_item.save
      redirect_to course_question_rubric_items_path @course, @question
    else
      flash[:error] = 'There was a problem saving your rubric item'
      render :new
    end
  end

  def edit
    @rubric_item = RubricItem.find_by_id(params[:id])
  end
  def update
    @rubric_item = RubricItem.find_by_id(params[:id])
    if @rubric_item.update_attributes(params[:rubric_item])
      redirect_to course_question_rubric_items_path @course, @question
    else
      render :action => "edit"
    end
  end

  def show
    @rubric_item = RubricItem.find_by_id(params[:id])
  end

  def index
    @rubric = @question.rubric_items
  end
  def destroy
    @rubric_item = RubricItem.find_by_id(params[:id])
    @rubric_item.destroy()
    redirect_to course_question_rubric_items_path @course, @question
  end
  private
  def load_question
    #TODO: Permissions for questions need to be respected here. Right now it's a wash.
    #if current_user.is_admin? or current_user.instructor_of?(@course)
    @course = Course.find(params[:course_id])
    @question = Question.find_by_id(params[:question_id])
    #end
    if not @question
      if @course
        redirect_to course_assignments_path(@course) and return
      else
        redirect_to account_url and return
      end
    end
  end

end

class CoursesController < ApplicationController

  load_and_authorize_resource :course

  def new
  end

  def create
    if @course.save 
      membership = CourseMembership.new(course: @course, user: current_user, role: CourseMembership.instructor_role)
	  if membership.save
        flash[:success] = "You've created '#{@course.name}.'"
        redirect_to @course
      else
        flash[:error] = "There was a problem adding your paper."
        @course.destroy
        render :new
      end
    else
      render :new
    end
  end

  def show
  end

  def index
  end

  def edit
  end

  def update
    if @course.update_attributes(params[:course])
      flash[:success] = "Updated '#{@course.name}.'"
      redirect_to @course
    else
      render :edit
    end
  end
  
  def switch
	@temp=ability.new
	temp.switch
  end
end

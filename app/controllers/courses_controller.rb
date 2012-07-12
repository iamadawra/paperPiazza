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

  def rate
    @course = Course.find(params[:id])
    @course.rate(params[:stars], current_user, params[:dimension])
    average = @course.rate_average(true, params[:dimension])
    width = (average / @course.class.max_stars.to_f) * 100
    render :json => {:id => @course.wrapper_dom_id(params), :average => average, :width => width}
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
end

class CourseMembershipsController < ApplicationController

  def create
    @course = Course.find(params[:course_id])

    if @course.has_member?(current_user)
      flash[:notice] = "You've already read this paper!"
      redirect_to courses_path and return
    end

    course_membership = CourseMembership.new(user: current_user, course: @course, role: CourseMembership.student_role)

    if course_membership.save
      flash[:success] = "You added #{@course.name} to your Reading List!"
      #Temporary fix. Refreshes the current page with the flash:
      redirect_to :back
      #OPTION TO REDIRECT TO COURSE PAGE:
      #redirect_to @course
    else
      flash[:error] = "Sorry, you were unable to read #{@course.name}. Please try again later."
      redirect_to courses_path
    end
  end

  def destroy
    @course = Course.find(params[:course_id])

    @course_membership = CourseMembership.find(params[:id])

    if not @course.has_member?(current_user)
      flash[:notice] = "You've not read this paper."
      redirect_to courses_path and return
    end

    @course_membership.destroy
    flash[:notice] = "You removed #{@course.name} from your Reading List!"
    redirect_to :back
    #redirect_to courses_path
  end

end

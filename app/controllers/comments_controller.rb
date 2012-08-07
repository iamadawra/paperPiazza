class CommentsController < ApplicationController

  # create a comment and bind it to an course and a user  
  def create
    @course = Course.find(params[:course_id])
    @comment = @course.comments.build(params[:comment])
    @comment.user = current_user

    respond_to do |format|
      if @course.state > 2
        if @comment.save
          format.html { redirect_to(@course, :notice => 'Comment was successfully created.') }
        else
          format.html { redirect_to(@course, :notice => 'There was an error saving your comment (empty comment or comment way to long).') }
        end
      else
        format.html { redirect_to(@course, :notice => 'Comments are limited to published courses.') }
      end  
    end
  end
  
  # remove a comment
  def destroy
    @comment = current_user.comments.find(params[:id])
    @course = course.find(params[:course_id])
    @comment.destroy
    
    respond_to do |format|
      format.html { redirect_to @course }
    end
  end
end
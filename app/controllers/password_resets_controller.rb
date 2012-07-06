class PasswordResetsController < ApplicationController
  def new
  end

  def edit
    @user = User.find_by_perishable_token(params[:id])
    unless @user
      flash[:error] = "The password reset link you followed was invalid. Please try again."
      redirect_to new_password_reset_path
    end
  end

  def update
    @user = User.find_by_perishable_token(params[:id])
    unless @user
      flash[:error] = "The password reset link you followed was invalid. Please try again."
      redirect_to new_password_reset_path and return
    end

    if @user.password_reset_sent_at < 4.hours.ago
      flash[:error] = "The password reset link you followed has expired. Please try again."
      redirect_to new_password_reset_path
    elsif @user.update_attributes(params[:user])
      flash[:success] = "Your password has been reset."
      redirect_to root_url
    else
      render :edit
    end
  end

  def create
    #TODO should we give up security and tell them we didn't find their email?
    user = User.find_by_email(params[:email])
    user.send_password_reset if user
    flash[:info] = "Instructions for resetting your password have been sent to your email address."
    redirect_to :root
  end

end

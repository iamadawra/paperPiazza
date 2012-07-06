class UserSessionsController < ApplicationController

  before_filter :require_no_user, only: [:new, :create]

  def new
  end
  
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      log_in user, params[:remember_me]
      redirect_back_or_to courses_url
    else
      flash.now[:error] = "Invalid email/password combination."
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

end

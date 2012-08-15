class AccountsController < ApplicationController

  before_filter :require_user,    only: [:show, :edit, :update]
  before_filter :require_no_user, only: [:new, :create]

  def show
    @user = current_user
  end

  def profile
    @user = User.find(params[:id])
  end

  def index
    @users = User.all
    respond_to do |format|
      format.html
      format.json { render :json => @users.map(&:attributes) }
    end
  end

  def edit
    @user = current_user
  end

  def new
    @user = User.new
  end

   def rate
    @course = Course.find(params[:id])
    @course.rate(params[:stars], current_user, params[:dimension])
    average = @course.rate_average(true, params[:dimension])
    width = (average / @course.class.max_stars.to_f) * 100
    render :json => {:id => @course.wrapper_dom_id(params), :average => average, :width => width}
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:success] = "Your account has been updated."
      redirect_to account_url
    else
      render :edit
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      UserMailer.welcome_email(@user).deliver
      log_in @user
      flash[:success] = "Welcome to paperPiazza!"
      redirect_to courses_url
    else
      render :new
    end
  end
end

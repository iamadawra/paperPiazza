class AccountsController < ApplicationController

  before_filter :require_user,    only: [:show, :edit, :update]
  before_filter :require_no_user, only: [:new, :create]

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def new
    @user = User.new
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

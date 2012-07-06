class UserMailer < ActionMailer::Base
  default from: "no-reply@paperpiazza.com"

  def welcome_email(user)
    @user = user
    @url  = "http://paperpiazza.com/"
    mail(:to => user.email, :subject => "Welcome to paperPiazza!")
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "paperpiazza.com Password Reset"
  end
end

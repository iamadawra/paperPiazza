module UserSessionsHelper

  def login_link
    if logged_in?
      link_to raw("<i class='icon-signout'></i> Log Out"), logout_path
    else
      link_to "Log In", login_path
    end
  end

  def log_in(user, remember_me=false)
    if remember_me
      cookies.permanent[:remember_token] = user.remember_token
    else
      cookies[:remember_token] = user.remember_token
    end
    current_user = user
  end

  def log_out
    current_user = nil
    cookies.delete(:remember_token)
  end

  def logged_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  def redirect_back_or_to(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  private

    def user_from_remember_token
      remember_token = cookies[:remember_token]
      User.find_by_remember_token(remember_token) unless remember_token.nil?
    end

    def clear_return_to
      session.delete(:return_to)
    end

end

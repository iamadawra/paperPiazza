class ApplicationController < ActionController::Base
  protect_from_forgery

  include UserSessionsHelper

  private

    def require_user
      unless logged_in?
        store_location
        redirect_to login_url, notice: "You must be logged in to access this page."
      end
    end

    def require_no_user
      redirect_to account_url, notice: "You must be logged out to access this page." if logged_in?
    end

end

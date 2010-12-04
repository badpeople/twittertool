# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def logged_in
    redirect_to "/" unless !current_user.nil?
  end

  def is_admin
    config_token  = APP_CONFIG[:auth_token]
    session_token = session[:auth_token]
    if !(session_token == config_token)
      redirect_to "/"
    end

  end

end

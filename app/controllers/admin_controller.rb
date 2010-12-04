class AdminController < ApplicationController

  before_filter :is_admin,:only=>[:enable_users,:disable_user]
  def index
    @session_token = session[:auth_token]
    config_token = APP_CONFIG[:auth_token]
        session_token = session[:auth_token]

    @is_admin = config_token == session_token

  end

  def set_auth_token
    @auth_token = params[:auth_token]
    session[:auth_token] = @auth_token
  end


  def enable_users
    @users = User.all
  end

  def disable_user
    user = User.find(params[:id])
    user.update_attribute(:enabled,false)
    redirect_to :action=>"enable_users"
  end



  def enable_user
    user = User.find(params[:id])
    user.update_attribute(:enabled,true)
    redirect_to :action=>"enable_users"
  end



end
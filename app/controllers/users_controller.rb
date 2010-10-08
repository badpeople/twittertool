class UsersController < ApplicationController
  include Util
  include Main

  before_filter :logged_in,:only=>[:tweets,:follow_test,:home]
  def tweets
    @tweets = current_user.twitter.get('/statuses/friends_timeline')
  end


  def follow_test
    follow(current_user)

  end

  def index
    if logged_in?
      redirect_to "/users/home"
    end

  end

  def home

  end






end

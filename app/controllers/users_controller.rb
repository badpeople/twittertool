class UsersController < ApplicationController
  include Util

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
    @my_keywords = current_user.keywords
  end

  def stats

#    @recent_friendings = recent_followed_usernames(current_user)
    @recent_friendings = Friending.find_all_by_user_id(current_user.id,:order=>"created_at")


  end

  def register


  end






end

class MimicsController < ApplicationController
  before_filter :logged_in

  def index
    @mimics = current_user.mimics
    @mimic = Mimic.new

  end
  
  def show
    @mimic = Mimic.find(params[:id])
  end
  
  def new
    @mimic = Mimic.new
  end

  def create
    begin
      @mimic = Mimic.new(params[:mimic])
      @mimic.user = current_user

      # get the id for the user
      # if this is a link get last path
      username = @mimic.twitter_username
      username = username[/\w*?$/]

      @mimic.twitter_username = username

      user_show = current_user.twitter.get("/users/show.json?screen_name=#{username}")

      @mimic.twitter_id = user_show['id']

      if @mimic.save
      end
    rescue => e
      flash[:error] = "Error trying to add #{params[:mimic][:twitter_username]}"
    end

    redirect_to :action =>  "index"
  end

  def destroy
    # make sure they own it
    @mimic = Mimic.find(params[:id])
    if @mimic.user = current_user
      @mimic.destroy
      flash[:notice] = "Successfully destroyed mimic."
      redirect_to mimics_url
    end
  end
end

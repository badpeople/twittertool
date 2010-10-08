class KeywordsController < ApplicationController
  before_filter :logged_in

  def index
    @my_keywords = current_user.keywords

    @all_keywords= Keyword.all - @my_keywords

    @keyword = Keyword.new

  end

  def attach
    keyword_id = params[:id]
    # check to make sure we dont already have this one
    keyword = Keyword.find(keyword_id)
    if !current_user.keywords.include?(keyword)
      current_user.keywords << keyword
    end
#    flash[:notice] = "Keyword added."

    redirect_to :action=>"index"

  end


  def remove
    keyword = Keyword.find(params[:id])
    current_user.keywords.delete(keyword)
#    flash[:notice] = "Keyword removed."

    redirect_to :action=>"index"

  end
  
  def show
    @keyword = Keyword.find(params[:id])
  end
  
  def new
    @keyword = Keyword.new
  end
  
  def create
    @keyword = Keyword.new(params[:keyword])
    @keyword.users << current_user
    if @keyword.save
      flash[:notice] = "Keyword added"
    end

    redirect_to :action=>"index"
  end
  
  def edit
    @keyword = Keyword.find(params[:id])
  end
  
  def update
    @keyword = Keyword.find(params[:id])
    if @keyword.update_attributes(params[:keyword])
      flash[:notice] = "Successfully updated keyword."
      redirect_to @keyword
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @keyword = Keyword.find(params[:id])
    @keyword.destroy
    flash[:notice] = "Successfully destroyed keyword."
    redirect_to keywords_url
  end
end

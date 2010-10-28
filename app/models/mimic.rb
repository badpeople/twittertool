class Mimic < ActiveRecord::Base
  belongs_to :user

  attr_accessible :twitter_id,:twitter_username

end

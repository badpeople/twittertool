class Tweet < ActiveRecord::Base
  belongs_to  :promotion
  belongs_to :user

  attr_accessible :deleted,:tweet_id,:promotion

end

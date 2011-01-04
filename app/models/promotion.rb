class Promotion < ActiveRecord::Base
  has_many :tweets
  attr_accessible :status_id,:text,:active
end

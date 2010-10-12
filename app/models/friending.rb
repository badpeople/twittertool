class Friending < ActiveRecord::Base
  belongs_to :user
#  set_table_name "friendings"

  attr_accessible :follow_id


end
class Keyword < ActiveRecord::Base
  attr_accessible :word
  has_and_belongs_to_many :users


end
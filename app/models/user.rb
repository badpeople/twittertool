class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_and_belongs_to_many :keywords
  has_many :friendings
  has_many :tweets
  has_many :mimics
  attr_accessible :enabled

  def self.all_enabled
    find_all_by_enabled(true)
  end

  def self.all_enabled_random
    find_all_by_enabled(true,:order=>"RAND()",:limit=>100)
  end

end

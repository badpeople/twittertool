class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_and_belongs_to_many :keywords
  has_many :friendings
  has_many :tweets
  has_many :mimics

end

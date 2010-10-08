# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_twittertool_session',
  :secret      => '7f1147c75ce40ee59b64d5ed89d1692f785abac02f6efd94f8b0516fb69c7da01accc1dbd3099dd63ed92771f4e33742b9950642acd9e4b83542c8e84cf5973f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

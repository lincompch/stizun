# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_trunk_session',
  :secret      => '106f9e45235ef26fcbdcb0cb93f4dd204eea1d7edfbecf331b8bac027ba13cff27b6f516760e843c8607f1af4e0ef462f654b92203595dce9925b18dc31d70dc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

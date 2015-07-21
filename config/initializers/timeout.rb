# config/initializers/timeout.rb
Rack::Timeout.timeout = 5 # seconds
# quiet the logger
Rack::Timeout.unregister_state_change_observer(:logger)

namespace :points do
  task :pull => :environment do 
    ParseEvent.pull_from_google
  end

  task :test_parse => :environment do 
  	require 'parse-ruby-client'
  	Parse.create :application_id => ENV['PARSE_APP_ID'], # required
           :api_key        => ENV['PARSE_API_KEY'], # required
           :quiet      => false  # optional, defaults to false
  end
end

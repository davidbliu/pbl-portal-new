require 'parse-ruby-client'

puts ENV['PARSE_APP_ID']
puts ENV['PARSE_MASTER_KEY']
client = Parse.create :application_id => ENV['PARSE_APP_ID'],
		              :api_key        => ENV['PARSE_MASTER_KEY'],
		              :quiet          => true 
puts client
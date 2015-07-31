require 'parse-ruby-client'
namespace :parse do

	task :golinks => :environment do 
		client = Parse.create :application_id => ENV['PARSE_APP_ID'],
		              :api_key        => ENV['PARSE_MASTER_KEY'],
		              :quiet          => true 
		puts client
	end
end
require "rubygems"
require "google/api_client"
require "google_drive"

require 'nokogiri'
require 'open-uri'
require 'timeout'

require 'set'

namespace :gdrive do
	task :scrape  => :environment do
		puts 'scraping google drive'
		puts SecureRandom.hex

		client = Google::APIClient.new
		auth = client.authorization
		auth.client_id = ENV['GOOGLE_INSTALLED_CLIENT_ID']
		auth.client_secret = ENV['GOOGLE_INSTALLED_CLIENT_SECRET']
		auth.scope = [
		  "https://www.googleapis.com/auth/drive",
		  "https://spreadsheets.google.com/feeds/",
		  'https://www.googleapis.com/auth/calendar'
		]
		auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
		auth.refresh_token = ENV['GOOGLE_DRIVE_REFRESH']
		auth.fetch_access_token!
		access_token = auth.access_token

		puts 'fetched access token'
		# Creates a session.
		session = GoogleDrive.login_with_oauth(access_token)
		files = Array.new

		# existing_urls = ParseGoLink.limit(10000000).all.map{|x| google_base_url(x.url)}
		# puts existing_urls


		linked_ids =  linked_resource_ids
		existing_keys = ParseGoLink.limit(100000000).map{|x| x.key}

		linked_files = Array.new
		unlinked_files = Array.new
		session.files do |file|
			if is_pbl_file(file)
				files << file
				if linked_ids.include?(file.resource_id.split(':')[1])
					linked_files << file
				else
					unlinked_files << file
				end
			end
		end
		puts 'finished scraping '+files.length.to_s+' files'

		puts 'saving '+unlinked_files.to_s + ' new links'
		golinks = Array.new
		unlinked_files.each do |file|
			key =  get_key(file, existing_keys).to_s
			description = file.title
			tags = get_tags(file)
			url = file.human_url

			if existing_keys.include?(key)
				puts '***this key already exists'
				puts "\t" + key
				key = key + '-' + SecureRandom.hex.to_s
				tags << 'duplicate'
			else
				puts key
				puts "\t" + description
				puts "\t" + tags.to_s
			end

			if not existing_keys.include?(key)
				golinks << ParseGoLink.new(member_email:'berkeleypbl.webdev@gmail.com', tags: tags, key: key, description: description, url: url, type:'scraped')
			end
			existing_keys << key
		end
		# puts 'saving ' + golinks.length.to_s + ' go links'
		# ParseGoLink.save_all(golinks)
		# 	golinks << ParseGoLink.new(member_email: 'berkeleypbl.webdev@gmail.com', tags: get_tags(file), key:)
	end
end


def is_pbl_file(file)
	title = file.title
	if title.include?('[') or title.include?('PBL')
		return true
	end
	return false
end

def get_key(file, existing_keys)
	title = file.title
	# remove []
	# title = title.split(']')[-1];
	title = title.gsub('[', ' ')
	title = title.gsub(']', ' ')
	title = title.gsub(/[^a-zA-Z0-9 -]/, '').gsub(/\s+/, '-').gsub('--', '-').gsub('--', '-') #/[!@#$%^&*()-=_+|;':",.<>?']/

	if title[0] == '-'
		title[0] = ''
	end
	if title[-1] == '-'
		title[-1] = ''
	end
	title =  title.downcase

	return title
end

""" gets tags """
def get_tags(file)
	title = file.title
	tags = Array.new
	tags << 'auto'
	# add tags for semester
	if title.include?("Fall 2013")
		tags << 'fall-13'
	end
	if title.include?("Spring 2014")
		tags << 'spring-14'
	end
	if title.include?("Fall 2014")
		tags << 'fall-14'
	end
	if title.include?("Spring 2015")
		tags << 'Spring-15'
	end
	if title.include?("Fall 2015")
		tags << 'fall-15'
	end
	if title.include?("Winter 2013")
		tags << 'winter-13'
	end
	if title.include?("Winter 2014")
		tags << 'winter-14'
	end
	if title.include?("Summer 2013")
		tags << 'summer-13'
	end
	if title.include?("Summer 2014")
		tags << 'summer-14'
	end

	# # get tags for committees
	# committees = ['co', 'cs', 'fi', 'ht', 'mk', 'pb', 'pd', 'so', 'wd', 'ex', 'in', 'of']
	# downcased_title = title.downcase
	# for committee in committees
	# 	if downcased_title.include?(committee)
	# 		tags << committee
	# 	end
	# end

	if title.include?('[')
		tags.concat title.split('[').select{|x| x!=''}.map{|x| x.split(']')[0]}
	end

	tags = tags.map{|x| x.downcase}
	tags = Set.new(tags).to_a
	return tags
end

def google_base_url(url)
	if url.include?('drive.google.com') or url.include?('docs.google.com')
		splits = url.split('/')
		return splits[0..splits.length-2].join('/')
	end
	return url
end

def get_resource_id(url)
	url.split("/")[-2]
end
def linked_resource_ids
	urls = ParseGoLink.limit(1000000).map{|x| x.url}.select{|x| x.include?('drive.google.com') or x.include?('docs.google.com')}.map{|x| get_resource_id(x)}
end
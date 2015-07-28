require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'archieml'

require 'nokogiri'
require 'open-uri'
require 'timeout'

namespace :elasticsearch do
	task :reindex => :environment do 
		ParseGoLink.import
		ParseGoLink.clearcache
		puts 'Reindexed ' + GoLink.all.length.to_s + ' go links at '+Time.now.to_s
		# send an email
		require 'timeout'
		status = Timeout::timeout(10) {
		  # Something that should be interrupted if it takes more than 5 seconds...
		  LinkNotifier.send_reindex_email
		}
	end
	task :scrape  => :environment do
		
		
		
		# create google client and array of data objects
		google_client = get_google_client
		search_data_objects = Array.new
		# search through docs in parse links
		doc_ids = Array.new
		parse_go_links = ParseGoLink.limit(10000).all.to_a # pulls from parse not from rails cache
		parse_go_links.each do |go_link|
			# for scraping google docs
			begin
				if go_link.url.include?('docs.google.com/document/d')
					doc_id = go_link.url.split('/')[5]
					# puts 'scraping: '+go_link.key
					# get fulltext
					fulltext = get_doc_text(google_client, doc_id)
					# puts fulltext
					search_data = ParseElasticsearchData.new
					search_data.go_link_id = go_link.id
					search_data.text = fulltext
					search_data_objects << search_data
				elsif go_link.url.include?('docs.google.com/spreadsheets')
					doc_id = go_link.url.split('/')[5]
					# puts 'scraping: '+go_link.key
					# get fulltext
					fulltext = get_spreadsheet_text(google_client, doc_id)
					# puts fulltext
					search_data = ParseElasticsearchData.new
					search_data.go_link_id = go_link.id
					search_data.text = fulltext
					search_data_objects << search_data
				end
			rescue
				puts 'problem: '+go_link.url
			end
		end
		# doc_ids.each do |datum|
		# 	link_id = datum[0]
		# 	doc_id = datum[1]
		# 	doc_text = get_doc_text(google_client, doc_id)
		# 	puts doc_text
		# 	search_data = ParseElasticsearchData.new
		# 	search_data.go_link_id = link_id
		# 	search_data.text = doc_text
		# 	search_data_objects << search_data
		# end
		# puts 'saving all records created from scraping!'
		ParseElasticsearchData.destroy_all
		ParseElasticsearchData.save_all(search_data_objects)
		puts 'Scraped and saved ' + ParseElasticsearchData.limit(100000).all.length.to_s + ' elasticsearch records at '+Time.now.to_s


		# send email that links were scraped
	end

	task :scrape_spreadsheets => :environment do 
		doc_id = '1JrFBumyLpepRCIdDYStSyATFYY8MRdp6r_n521_Kiyc'
		client = get_google_client
		doc_text = get_doc_text(client, doc_id)
		puts doc_text
	end

	# still need to scrape other resources like spreadsheets and generic links
end 


def get_google_client
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
	auth.refresh_token = ENV['REFRESH_TOKEN']
	return client
end


def get_doc_text(client, doc_id)
	client.authorization.fetch_access_token!
	drive = client.discovered_api('drive', 'v2')
	result = client.execute(
	  :api_method => drive.files.get,
	  :parameters => { 'fileId' => doc_id })

	text_url = result.data['exportLinks']['text/plain']
	text_aml = client.execute(uri: text_url).body.gsub(/\s+/, ' ')
	return text_aml
end

def get_spreadsheet_text(client, spreadsheet_id)
	client.authorization.fetch_access_token!
	access_token = client.authorization.access_token
	session = GoogleDrive.login_with_oauth(access_token)
	ws = session.spreadsheet_by_key(spreadsheet_id).worksheets[0]
	fulltext = ""
	ws.rows.each do |row|
		row.each do |cell|
			fulltext += cell + " "
		end
	end
	return fulltext
end


def get_url_fulltext(url)
	html = Nokogiri::HTML(open url)
	text  = html.at('body').inner_text
	# Pretend that all words we care about contain only a-z, 0-9, or underscores
	words = text.scan(/\w+/)
	# words that are only letters
	# words = text.scan(/[a-z]+/i)
	fulltext = ''
	words.each do |word|
		fulltext += word + ' '
	end
	return fulltext.gsub(/\s+/, ' ')
end
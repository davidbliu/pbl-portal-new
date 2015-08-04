require "rubygems"
require "google/api_client"
require "google_drive"

require 'nokogiri'
require 'open-uri'
require 'timeout'

require 'set'

tab = "---->"
namespace :gdrive do

	task :scrape => :environment do 
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

		# Creates a session.
		session = GoogleDrive.login_with_oauth(access_token)

		# set global variables
		$files = 0
		$existing_golinks = ParseGoLink.limit(100000000).all.to_a
		$existing_keys = $existing_golinks.map{|x| x.key}
		$existing_urls = $existing_golinks.map{|x| x.url}
		$scraped_links = Array.new
		$skip = Array.new # what folders to skip

		$skip << "[PBL][EX] Fall 2015"
		$skip << "![PBL][EX] Semester Officer Management "
		$skip << "[PBL][CO] Consulting"
		$skip << "[PBL][WD] Web Development"
		$skip << "Committee Collaborations"
		$skip << "[PBL][FI] Finance"
		$skip << "[PBL][PD] Professional Development"
		$skip << ""

		$threads = []


		# start scraping
		collections = session.collections
		collections.each do |collection|
			scrape_subcollection(collection, Array.new)
		end

		$threads.each(&:join)
		puts 'finished scraping drive'

		
	end

	def scrape_subcollection(collection, previous_titles, tags = Array.new)
		level = previous_titles.length
		level_string = ''
		for lvl in 0..level
			level_string += '..'
		end
		# puts level_string + collection.title + ' ('+collection.files.length.to_s+' files)'
		print '.'
		# dont do anything if you need to skip the file
		if not $skip.include?(collection.title)
			# timeout on scraping fiels just in case
			begin
				status = Timeout::timeout(60) {
				  # Something that should be interrupted if it takes more than 5 seconds...
				  scrape_files(collection, previous_titles)
				}
			rescue
				puts ' timeout'
			end
			
			cumulative_titles = previous_titles.clone
			cumulative_titles << collection.title
			collection.subcollections.each do |subcollection|
				until $threads.map {|t| t.alive?}.count(true) < 500 do 
					sleep 5
				end
				t = Thread.new{
					scrape_subcollection(subcollection, cumulative_titles)
				}
				$threads << t
			end
		else
			# puts ' skipped'
		end
	end

	def scrape_files(collection, directories)
		tags = Array.new
		dirs = directories.clone
		dirs << collection.title
		dirs.each do |directory|
			tags = tags + get_tags2(directory)
		end

		dir_files = Array.new
		golinks = Array.new
		collection.files do |file|
			# update tags for the file
			file_tags = tags + get_tags2(file.title)
			file_tags = Set.new(file_tags).to_a
			# puts file.title
			# puts file_tags.join(',')
			key = get_key(file)
			url = file.human_url
			description = file.title
			if not $existing_urls.include?(url)
				if $existing_keys.include?(key)
					key += '-'+SecureRandom.hex.to_s
					file_tags << "duplicated"
				end
				golinks << ParseGoLink.new(member_email:'berkeleypbl.machine@gmail.com', tags: file_tags, key: key, description: description, url: url, type:'scraped')
				puts golink.name
			end
		end
		# save all golinks 
		if golinks.length > 0
			ParseGoLink.save_all(golinks)
			$scraped_links.concat(golinks)
			# print ' +'+golinks.length.to_s
		end

		# puts ''
	end

	task :scrape2  => :environment do
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

		# Creates a session.
		session = GoogleDrive.login_with_oauth(access_token)
		files = Array.new
		existing_golinks = ParseGoLink.limit(100000000).all.to_a
		existing_keys = existing_golinks.map{|x| x.key}
		existing_urls = existing_golinks.map{|x| x.url}

		i = 0
		linked_files = Array.new
		unlinked_files = Array.new
		session.files do |file|
			files << file
			if existing_urls.include?(file.human_url)
				linked_files << file
			else
				unlinked_files << file
			end
			puts i 
			i+=1
		end
		puts 'finished scraping '+files.length.to_s+' files'
		puts 'saving '+unlinked_files.length.to_s + ' new links'

		# create message to send about links you are saving
		messages = Array.new
		saved_urls = Array.new
		golinks = Array.new
		unlinked_files.each do |file|
			key =  get_key(file, existing_keys).to_s
			description = file.title
			tags = get_tags(file.title)
			url = file.human_url

			if existing_keys.include?(key) 
				if not existing_urls.include?(url) # if it is already a url, then dont save it
					key = key + '-' + SecureRandom.hex.to_s
					tags << 'duplicate'
					puts '***this key already exists, creating a duplicate with random hash name'
					puts "\t" + key
					puts "\t" + url
					messages <<  '***this key already exists, creating a duplicate with random hash name'
					messages <<  (tab  + key)
					messages <<  (tab + url)
				end
			else
				puts key
				puts "\t" + description
				puts "\t" + tags.to_s
				messages <<  key
				messages <<  (tab + description)
				messages <<  (tab + tags.to_s)
			end

			if not existing_keys.include?(key)
				golinks << ParseGoLink.new(member_email:'berkeleypbl.machine@gmail.com', tags: tags, key: key, description: description, url: url, type:'thread_scraped')
				saved_urls << url
			end
			existing_keys << key
			existing_urls << url
		end
		puts 'saving ' + golinks.length.to_s + ' go links'
		ParseGoLink.save_all(golinks)

		# send email notifying of scrape
		status = Timeout::timeout(10) {
		  # Something that should be interrupted if it takes more than 10 seconds...
		  LinkNotifier.send_gdrive_scraped_email(messages, Array.new)
		}
	end
end


def is_pbl_file(file)
	title = file.title
	if title.include?('[') or title.include?('PBL')
		return true
	end
	return false
end

def get_key(file)
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

def get_semester_tags(title)
	semesters = Array.new
	seasons = ["fall", "spring", "winter", "summer"]
	years = ["2010", "2011", "2012", "2013", "2014", "2015", "2016"]
	seasons.each do |season|
		years.each do |year|
			semesters << season + " "+year
		end
	end
	tags = Array.new
	for semester in semesters 
		if title.include?(semester)
			tags << semester
		end
	end
	return tags
end

def get_committee_tags(title)
end

def get_keyword_tags(title)
	terms = Hash.new
	terms["cases"] = ["case competition", "case", "cases"]
	terms["resources"] = ["resource", "resources"]
	terms["interview"] = ["interview"]
	terms["workshops"] = ["workshops", "workshop"]
	terms["books"] = ["books"]
	terms["studies"] = ["studies"]
	terms["budget"] = ["budget"]
	terms["blog"] = ["blog"]
	terms["agendas"] = ["agenda", "agendas"]
	terms["newsletters"] = ["newsletter"]
	terms["yearbook"] = ["yearbook", "yearbook pages"]
	terms["deliverables"] = ["deliverable", "deliverables"]
	terms["collaborations"] = ["collaboration", "collaboration"]
	terms["videos"] = ["video", "videos"]
	terms["notes"] = ["notes"]
	terms["nexus"] = ["nexus"]
	terms["novum"] = ["novum"]
	terms["recruitment"] = ["recruitment", "recruiting"]
	terms["feedback"] = ["feedback"]
	terms["meetings"] = ["meetings"]
	terms["applications"] = ["application", "applications", "applicants"]
	terms["presentations"] = ["presentantions", "presentation"]
	terms["chair"] = ["chair"]
	terms["admin"] = ["admin"]
	terms["committee review"] = ["committee review"]
	terms["committee"] = ["committee", " cm "]
	terms["interviews"] = ["interview", "interviews"]
	terms["ex"] = ["[ex]", "exec", "vp "]
	terms["cs"] = ["[cs]", " cs ", "community service"]
	terms["co"] = ["[co]", " co ", "consulting"]
	terms["fi"] = ["[fi]", "finance", " fi "]
	terms["ht"] = ["[ht]", "historian", " ht "]
	terms["mk"] = ["[mk]", "marketing", " mk "]
	terms["so"] = ["[so]", "social", " so "]
	terms["pb"] = ["[pb]", "publications", " pb ", "pubs"]
	terms["pd"] = ["[pd]", "professional development", " pd ", "nexus"]
	terms["wd"] = ["[wd]", "web development", " wd ", "neon"]
	terms["in"] = ["[in]", "internal networking", " in "]
	terms["of"] = ["[of]", "officer", " of "]
	document_types = ['ai', 'pdf', 'ppt', 'pptx', 'ppx', 'doc', 'img', 'png', 'jpg', 'jpeg']
	for doctype in document_types
		terms[doctype] = [doctype]
	end
	single_words = ['retreat', 'canvassing', 'concessions']
	for single_word in single_words
		terms[single_word] = [single_word]
	end


	tags = Array.new
	for term in terms.keys
		for termx in terms[term]
			if title.include?(termx)
				tags << term
			end
		end
	end
	return tags
end

def get_event_tags(title)
end

def get_doctype_tags(title)
end

def get_directory_tags(title)
end

def get_tags2(title)
	title = title.downcase
	tags = get_semester_tags(title)
	tags = tags + get_keyword_tags(title)
end

""" gets tags """
def get_tags(title)
	# title = file.title
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

	# add tags for document types
	document_types = ['ai', 'pdf', 'ppt', 'pptx', 'ppx', 'doc', 'img', 'png', 'jpg', 'jpeg']
	
	for docType in document_types
		if title.downcase.include?("." + docType)
			tags << docType
		end
	end

	# add tags for key terms
	terms = ["meeting", "budget", "event", "request", "resource", "interview", "workshop", "agenda", "newsletter", "yearbook", "page", 
		"responses", "checkin", "chum", "check-in", "blog"]

	for term in terms
		if title.downcase.include?(term)
			tags << term
		end
	end

	if title.include?('[')
		tags.concat title.split('[').select{|x| x!=''}.map{|x| x.split(']')[0]}
	end

	tags = tags.map{|x| x.downcase}
	tags = Set.new(tags).to_a
	return tags
end
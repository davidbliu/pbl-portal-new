
require "rubygems"
require "google/api_client"
require "google_drive"

# Authorizes with OAuth and gets an access token.
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
# print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
# print("2. Enter the authorization code shown in the page: ")
# auth.code = $stdin.gets.chomp
auth.fetch_access_token!
# access_token = auth.access_token

# refresh_token = auth.refresh_token# cal.login_with_auth_code( $stdin.gets.chomp )

# puts "\nMake sure you SAVE YOUR REFRESH TOKEN so you don't have to prompt the user to approve access again."
# puts "your refresh token is:\n\t#{refresh_token}\n"
# puts "Press return to continue"
# $stdin.gets.chomp
access_token = auth.access_token
puts 'this is the access token : ' + access_token
# Creates a session.
session = GoogleDrive.login_with_oauth(access_token)

# Gets list of remote files.
session.files.each do |file|
	
	# p file.resource_type
	if file.resource_type == "document"
		begin
			p file.title
			puts 'is a file'
			puts file.download_to_string
			puts "SUCCESSFUL"
		rescue
			p '' 
		end
	end
end

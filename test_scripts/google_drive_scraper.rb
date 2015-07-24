require "rubygems"
require "google/api_client"
require "google_drive"

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
auth.fetch_access_token!
# access_token = auth.access_token

# FILE_ID  = '1IhvgxbhW8dhtdxyNXBsGPM63lKgkgxv_AOBJgGsV4-Y'

# drive = client.discovered_api('drive', 'v2')
# result = client.execute(
#   :api_method => drive.files.get,
#   :parameters => { 'fileId' => FILE_ID })

# text_url = result.data['exportLinks']['text/plain']
# text_aml = client.execute(uri: text_url).body.gsub(/\s+/, ' ')
# puts text_aml # this is the string we're interested in

# Creates a session.
# session = GoogleDrive.login_with_oauth(access_token)

# session.files.each do |file|
# 	if file.resource_type == "document"
# 		begin
# 			p file.title
# 			puts 'is a file'
# 			puts file.download_to_string
# 			puts "SUCCESSFUL"
# 		rescue
# 			p '' 
# 		end
# 	end
# end

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

spreadsheet_id = '1JrFBumyLpepRCIdDYStSyATFYY8MRdp6r_n521_Kiyc'
puts get_spreadsheet_text(client, spreadsheet_id)

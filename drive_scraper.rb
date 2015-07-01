require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'archieml'

client = Google::APIClient.new(:application_name => 'Ruby Drive sample', :application_version => '1.0.0')
flow = Google::APIClient::InstalledAppFlow.new(
  :client_id => ENV['GOOGLE_INSTALLED_CLIENT_ID'],
  :client_secret => ENV['GOOGLE_INSTALLED_CLIENT_SECRET'],
  :scope => ['https://www.googleapis.com/auth/drive']
)
client.authorization = flow.authorize


FILE_ID  = '1IhvgxbhW8dhtdxyNXBsGPM63lKgkgxv_AOBJgGsV4-Y'
FILE_ID_2 = '1XGA2ZoqLvzkfkUxfXOwyy24bhxklKgr2oZf3ZRhciwk'
drive = client.discovered_api('drive', 'v2')

result = client.execute(
  :api_method => drive.files.get,
  :parameters => { 'fileId' => FILE_ID })

text_url = result.data['exportLinks']['text/plain']
text_aml = client.execute(uri: text_url).body.gsub(/\s+/, ' ')
parsed = Archieml.load(text_aml)

puts text_aml # this is the string we're interested in
puts parsed




""" get all link urls from parse and foreach find the file """

result = client.execute(
  :api_method => drive.files.get,
  :parameters => { 'fileId' => FILE_ID_2 })

text_url = result.data['exportLinks']['text/plain']
text_aml = client.execute(uri: text_url).body.gsub(/\s+/, ' ')
puts text_aml
namespace :elasticsearch do
	task :scrape_docs  => :environment do
		require 'google/api_client'
		require 'google/api_client/client_secrets'
		require 'google/api_client/auth/installed_app'
		require 'archieml'
		ParseElasticsearchData.destroy_all
		# get doc ids
		doc_ids = Array.new
		parse_go_links = ParseGoLink.hash.values
		parse_go_links.each do |go_link|
			if go_link.url.include?('docs.google.com/document/d')
				doc_id = go_link.url.split('/')[5]
				puts doc_id
				doc_ids << [go_link.id, doc_id]
			end
		end

		google_client = get_google_client
		search_data_objects = Array.new
		doc_ids.each do |datum|
			link_id = datum[0]
			doc_id = datum[1]
			doc_text = get_doc_text(google_client, doc_id)
			puts doc_text
			search_data = ParseElasticsearchData.new
			search_data.go_link_id = link_id
			search_data.text = doc_text
			search_data_objects << search_data
		end

		ParseElasticsearchData.save_all(search_data_objects)


	end
end 


def get_google_client
	client = Google::APIClient.new(:application_name => 'Ruby Drive sample', :application_version => '1.0.0')
	flow = Google::APIClient::InstalledAppFlow.new(
	  :client_id => ENV['GOOGLE_INSTALLED_CLIENT_ID'],
	  :client_secret => ENV['GOOGLE_INSTALLED_CLIENT_SECRET'],
	  :scope => ['https://www.googleapis.com/auth/drive']
	)
	client.authorization = flow.authorize
	return client
end

def get_doc_text(client, doc_id)
	drive = client.discovered_api('drive', 'v2')
	result = client.execute(
	  :api_method => drive.files.get,
	  :parameters => { 'fileId' => doc_id })

	text_url = result.data['exportLinks']['text/plain']
	text_aml = client.execute(uri: text_url).body.gsub(/\s+/, ' ')
	return text_aml
end
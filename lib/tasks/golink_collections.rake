namespace :golinks do

	task :collection => :environment do
		yaml_string = File.read('collection.yaml')
		puts yaml_string
		data =  YAML.load(yaml_string)
		puts 'creating a collection'
		ParseGoLinkCollection.create(data: data.to_json, name: data['name'])
	end

	task :test_collection => :environment do
		collection = ParseGoLinkCollection.all.to_a[0]
		data = JSON.parse(collection.data)
		puts data.keys
	end
end
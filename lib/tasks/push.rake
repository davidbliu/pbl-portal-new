task :push_app => :environment do 
	app = Rpush::Gcm::App.new
	app.name = "chrome"
	app.auth_key = "..."
	app.connections = 1
	app.save!
end

task :push_notification => :environment do
	n = Rpush::Gcm::Notification.new
	n.app = Rpush::Gcm::App.find_by_name("chrome")
	n.registration_ids = NotificationClient.all.map{|x| x.registration_id}
	n.data = { message: "hi mom!" }
	n.save!
end


require 'gcm'
task :push => :environment do

	gcm = GCM.new(ENV["GOOGLE_PUSH_API_KEY"])
	# you can set option parameters in here
	#  - all options are pass to HTTParty method arguments
	#  - ref: https://github.com/jnunemaker/httparty/blob/master/lib/httparty.rb#L40-L68
	#  gcm = GCM.new("my_api_key", timeout: 3)

	registration_ids= NotificationClient.all.map{|x| x.registration_id}
	puts 'pushing a notification out'
	options = options = {data: {id: 'another id', title: 'HT workshoasdfp 1', message: "here are the links for our first workshop", type:'links', keys: 'fb group, fb-gender, mission'}, collapse_key: "updated_score"}
	response = gcm.send(registration_ids, options)
	puts response
end
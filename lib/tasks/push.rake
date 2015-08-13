

require 'gcm'
task :push => :environment do

	gcm = GCM.new(ENV["GOOGLE_PUSH_API_KEY"])
	# you can set option parameters in here
	#  - all options are pass to HTTParty method arguments
	#  - ref: https://github.com/jnunemaker/httparty/blob/master/lib/httparty.rb#L40-L68
	#  gcm = GCM.new("my_api_key", timeout: 3)

	registration_ids= NotificationClient.where(email:'davidbliu@gmail.com').map{|x| x.registration_id}
	random_id = SecureRandom.hex.to_s
	puts 'pushing a notification out'
	options = options = {data: {id: random_id, title: 'Mission', message: "a new link was added: pbl.link/mission", type:'links', key:'mission'}, collapse_key: "updated_score"}
	response = gcm.send(registration_ids, options)
	puts response
end
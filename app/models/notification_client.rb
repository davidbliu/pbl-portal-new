require 'gcm'
class NotificationClient < ParseResource::Base
	fields :email, :registration_id, :data

	def self.push(recipients, message, link)
		# registration_ids= NotificationClient.where(email:'davidbliu@gmail.com').map{|x| x.registration_id}
		# registration_ids = NotificationClient.all.map{|x| x.registration_id}
		gcm = GCM.new(ENV["GOOGLE_PUSH_API_KEY"])

		registration_ids = NotificationClient.limit(100000).all.select{|x| recipients.include?(x.email)}.map{|x| x.registration_id}
		random_id = SecureRandom.hex.to_s
		puts 'pushing a notification out'
		options = options = {data: {id: random_id, title: 'PBL Link Notifier', message: message, type:'links', key:link}, collapse_key: "updated_score"}
		response = gcm.send(registration_ids, options)
		puts response
	end
end
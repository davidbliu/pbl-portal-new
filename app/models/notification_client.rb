require 'gcm'
class NotificationClient < ParseResource::Base
	fields :email, :registration_id, :data

	def self.push(recipients, message, link)
		# registration_ids= NotificationClient.where(email:'davidbliu@gmail.com').map{|x| x.registration_id}
		# registration_ids = NotificationClient.all.map{|x| x.registration_id}
		gcm = GCM.new(ENV["GOOGLE_PUSH_API_KEY"])

		registration_ids = NotificationClient.limit(100000).all.select{|x| recipients.include?(x.email)}.map{|x| x.registration_id}
		
		# puts 'pushing a notification out to '+registration_ids.to_s
		# puts 'using the key '+ENV['GOOGLE_PUSH_API_KEY']
		options = options = {data: {id: SecureRandom.hex.to_s, title: 'PBL Link Notifier', message: message, type:'links', key:link}, collapse_key: "updated_score"}
		response = gcm.send(registration_ids, options)
		return response
	end
end
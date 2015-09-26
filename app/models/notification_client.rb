require 'gcm'
class NotificationClient < ParseResource::Base
	fields :email, :registration_id, :data

	def self.register(email, chrome_id)
		r = NotificationClient.where(email:email).to_a
		if r.length == 0
			r = NotificationClient.new(email:email)
		else
			r = r[0]
		end
		r.registration_id = chrome_id
		r.save
	end
	def self.push(sender, recipients, title, message, link)
		# registration_ids= NotificationClient.where(email:'davidbliu@gmail.com').map{|x| x.registration_id}
		# registration_ids = NotificationClient.all.map{|x| x.registration_id}
		gcm = GCM.new(ENV["GOOGLE_PUSH_API_KEY"])
		email_resolve_hash = SecondaryEmail.email_resolve_hash
		valid_emails = SecondaryEmail.valid_emails
		recipient_emails = []
		recipients.each do |email|
			if email and email != '' and valid_emails.include?(email)
				secondary_emails = email_resolve_hash[email]
				if secondary_emails
					recipient_emails.concat(secondary_emails)
				end
				recipient_emails << email
			end
		end

		registration_ids = NotificationClient.limit(100000).all.select{|x| recipient_emails.include?(x.email)}.map{|x| x.registration_id}
		
		# puts 'pushing a notification out to '+registration_ids.to_s
		# puts 'using the key '+ENV['GOOGLE_PUSH_API_KEY']
		options = options = {data: {id: SecureRandom.hex.to_s, title: title, message: message,timestamp:Time.now.to_s,sender: sender ? sender.name : 'none', type:'links', key:link}, collapse_key: "updated_score"}
		response = gcm.send(registration_ids, options)
		return response
	end
end
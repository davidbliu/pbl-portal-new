class PushNotifier

	def self.send_push
		@@my_logger ||= Logger.new("#{Rails.root}/log/go.log")
	end

end
class GoLog

def self.logger
	@@my_logger ||= Logger.new("#{Rails.root}/log/go.log")
end


	def self.log_click(email, key, time)
		delimiter = ' || '
		self.logger.info(email.to_s + delimiter +key.to_s + delimiter + time.to_s )
	end
end
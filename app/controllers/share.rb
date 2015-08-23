require 'timeout'
class Share < ParseResource::Base
	fields :sender, :recipient, :message, :links, :time, :message_id, :all_recipients


	def time_string
		time = self.time.in_time_zone("Pacific Time (US & Canada)")
		time.strftime("%b %e, %Y at %l:%M %p")
	end
end
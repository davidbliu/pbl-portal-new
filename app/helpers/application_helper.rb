module ApplicationHelper

	def avatar_url(email)
		gravatar_id = Digest::MD5.hexdigest(email.downcase)
    	return "http://gravatar.com/avatar/#{gravatar_id}.png"
	end

end

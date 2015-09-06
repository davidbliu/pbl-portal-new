module ApplicationHelper

	def avatar_url(email)
		gravatar_id = Digest::MD5.hexdigest(email.downcase)
    	return "http://gravatar.com/avatar/#{gravatar_id}.png"
	end

	def loading_image
		"http://wpc.077d.edgecastcdn.net/00077D/fender/images/2013/template/drop-nav-loader.gif"
	end

end

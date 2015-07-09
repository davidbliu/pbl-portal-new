class GoLinkFavorite < ParseResource::Base

	fields :key, :member_email, :time

	def self.hash
		h = Hash.new
		GoLinkFavorite.limit(10000).all.each do |favorite|
			if not h.keys.include?(favorite.member_email)
				h[favorite.member_email] = Array.new
			end
			h[favorite.member_email] << favorite.key
		end
		return h
	end
end
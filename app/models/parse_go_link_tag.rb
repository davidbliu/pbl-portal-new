class ParseGoLinkTag < ParseResource::Base
	fields :name, :color

	def self.color_hash
		chash = Rails.cache.read('tag_color_hash')
		if chash != nil
			return chash
		end
		chash = ParseGoLinkTag.limit(10000).all.index_by(&:name)
		Rails.cache.write('tag_color_hash', chash)
		return chash
	end
end
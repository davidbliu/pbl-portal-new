class FeaturedContent < ParseResource::Base
	fields :name, :content

	def self.home_content
		Rails.cache.fetch 'home_content' do 
			hc = FeaturedContent.where(name: 'home_content').first
			return hc ? hc.content : nil
		end
	end

	def self.content_keys
		['home_content']
	end
end
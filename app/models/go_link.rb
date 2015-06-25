class GoLink < ActiveRecord::Base
	attr_accessible :key, :url, :description

	def self.go_link_hash
		go_hash = Rails.cache.read('go_link_hash')
		if go_hash != nil
			return go_hash
		end

		go_hash = Hash.new
		GoLink.all.each do |golink|
			go_hash[golink.key] = golink
		end
		Rails.cache.write('go_link_hash', go_hash)
		return go_hash
	end

	def self.go_link_id_hash
		return GoLink.all.index_by(&:id)
	end
end

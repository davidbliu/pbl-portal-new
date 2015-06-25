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


	def self.catalogue_by_resource_type
		types = Array.new
		types_keyword = Array.new

		types << 'drive'
		types_keyword << 'drive.google.com'

		types << 'docs'
		types_keyword << 'docs.google.com'

		types << 'piazza'
		types_keyword << 'piazza.com'

		types << 'portal'
		types_keyword << '.berkeley-pbl.com'

		types << 'forms'
		types_keyword << '/viewform'

		# types << 'other'
		# types_keyword << ''
		# set up result hash
		result = Hash.new
		types.each do |type|
			result[type] = Array.new
		end
		result['other'] = Array.new
		# populate result hash with list of links for each type
		link_hash = self.go_link_id_hash
		link_hash.keys.each do |id|
			url = link_hash[id].url
			matches = 0
			types.each_with_index do |type, index|
				if url.include?(types_keyword[index])
					result[type] << id
					matches = matches + 1
				end
			end
			if matches == 0
				result['other'] << id
			end
		end
		puts 'this is the result'
		puts result
		return result

	end
end

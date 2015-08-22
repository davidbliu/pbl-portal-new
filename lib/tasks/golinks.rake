namespace :golinks do

	task :tags => :environment do 
		golinks = ParseGoLink.limit(1000000).all.to_a
		tag_hash = Hash.new
		golinks.each do |golink|
			puts golink.key
			golink.get_tags.each do |tag|
				if not tag_hash.keys.include?(tag)
					tag_hash[tag] = Array.new
				end
				tag_hash[tag] << golink.id
			end
		end
		tag_hash.keys.each do |tag|
			TagHistogram.create(tag: tag, ids: tag_hash[tag])
		end
	end
end
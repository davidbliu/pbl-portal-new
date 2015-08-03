require 'dalli'
require 'timeout'
namespace :memcached do
	task :cache_golinks => :environment do 
		# puts 'pulling links from parse'
		golinks = ParseGoLink.limit(1000000).all.to_a

		go_key_hash = golinks.index_by(&:key)

		golink_key_hash = Hash.new # key to list of golinks
		keyset = Set.new
		golinks.each do |golink|
			if not keyset.include?(golink.key)
				golink_key_hash[golink.key] = Array.new
				keyset << golink.key
			end
			golink_key_hash[golink.key] << golink 
		end
		dc = dalli_client
		dc.set('golink_key_hash', golink_key_hash)
		dc.set('go_key_hash', go_key_hash)
		dc.set('golinks', golinks)
		key_hash = dc.get('go_key_hash')
		
		golinks = go_key_hash.values
		tags = Set.new(golinks.map{|x| x.tags}.select{|x| x != nil and x!= ""}.flatten()).to_a.sort
		tag_links = Hash.new
		tags.each do |tag|
			tag_links[tag] = golinks.select{|x| x.tags ? x.tags.include?(tag) : false}
		end
		dc.set('tag_links', tag_links)

		# save tag information
		dc.set('go_tags', tags)
		puts 'finished writing to memcached '+Time.now.to_s

		
		# # send memcached email
		# status = Timeout::timeout(10) {
		#   # Something that should be interrupted if it takes more than 5 seconds...
		#   LinkNotifier.send_memcached_email
		# }
	end

	task :get_golinks => :environment do
		puts 'started'
		puts dalli_client.get('go_key_hash').values.map{|x| x.url}
	end
end


def dalli_client
	options = { :namespace => "app_v1", :compress => true }
	dc = Dalli::Client.new(ENV['MEMCACHED_HOST'], options)
end
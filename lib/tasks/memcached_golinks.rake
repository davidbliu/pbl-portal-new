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
		dc.set('golinks_hash', golinks.index_by(&:id))
		key_hash = dc.get('go_key_hash')
		
		# golinks = go_key_hash.values
		# tags = Set.new(golinks.map{|x| x.tags}.select{|x| x != nil and x!= ""}.flatten()).to_a.sort
		# tag_links = Hash.new
		# tags.each do |tag|
		# 	tag_links[tag] = golinks.select{|x| x.tags ? x.tags.include?(tag) : false}
		# end
		# dc.set('tag_links', tag_links)

		# # save tag information
		# dc.set('go_tags', tags)
		# dc.set('golinks_already_caching', nil)
		puts 'finished writing to memcached '+Time.now.to_s

		
		# # send memcached email
		# status = Timeout::timeout(10) {
		#   # Something that should be interrupted if it takes more than 5 seconds...
		#   LinkNotifier.send_memcached_email
		# }
	end
	task :cache_bundles_permissions => :environment do 
		ParseGoLinkBundle.cache_permissions
		puts 'finished writing to bundle permissions at '+Time.now.to_s
	end

	task :cache_permissions => :environment do 
		# puts 'pulling golinks'
		golinks = ParseGoLink.limit(10000000).all.to_a
		# puts 'getting groups hash'
		groups_golink_hash = Hash.new
		group_keys = Array.new
		groups_golink_hash['all'] = Array.new
		golinks.each do |golink|
			if not golink.groups
				groups_golink_hash['all'].add(golink.id)
			else
				golink.groups.each do |group|
					if not group_keys.include?(group)
						groups_golink_hash[group] = Set.new
					end
					groups_golink_hash[group].add(golink.id)
				end
			end
		end
		
		# puts 'pulling groups'
		golink_groups = ParseGroup.limit(100000).all.to_a
		# puts 'pulled groups'
		# puts 'getting permissions hash'

		""" the permissions hash is a hash from member emails to a set of ids that the member can access """
		# puts 'pulling members'
		members = ParseMember.limit(1000000).all.to_a
		# puts 'pullled members'
		permissions_hash = Hash.new
		all_set = groups_golink_hash['all']
		# permissions_hash['all'] = groups_golink_hash['all']
		included_emails = Set.new
		golink_groups.each do |group|
			group_golink_ids = groups_golink_hash[group.name].to_a
			group.member_emails.each do |email|
				if not included_emails.include?(email)
					included_emails << email
					permissions_hash[email] = all_set
				end
				permissions_hash[email].union(group_golink_ids)
			end
		end

		dc = dalli_client
		dc.set('golink_permissions_hash', permissions_hash)
		puts 'finished writing permissions to memcached at '+Time.now.to_s
		# puts 'testing permissions'
		# permissions = dc.get('golink_permissions_hash')
		# golinks = dc.get('golinks')
		# puts 'streaming'
		# puts golinks.select{|x| permissions['davidbliu@gmail.com'].include?(x.id)}.map{|x| x.key}
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
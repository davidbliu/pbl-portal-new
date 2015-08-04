require 'set'
namespace :golinks do

	task :golink_permissions => :environment do
		puts 'pulling golinks'
		golinks = ParseGoLink.limit(10000000).all.to_a
		puts 'getting groups hash'
		groups_golink_hash = Hash.new
		group_keys = Set.new
		groups_golink_hash['all'] = Set.new
		golinks.each do |golink|
			if not golink.groups or golinks.groups.length == 0
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
		
		puts 'pulling groups'
		golink_groups = ParseGroup.limit(100000).all.to_a
		puts 'pulled groups'
		puts 'getting permissions hash'

		""" the permissions hash is a hash from member emails to a set of ids that the member can access """
		puts 'pulling members'
		members = ParseMember.limit(1000000).all.to_a
		puts 'pullled members'
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
		# puts permissions_hash
		# puts permissions_hash["davidbliu@gmail.com"].to_a
	end

	task :bundle_permissions=>:environment do 
		puts 'caching permissions'
		ParseGoLinkBundle.cache_permissions
		puts 'finished caching permissions'

		puts 'testing permissions'
		my_bundles = ParseGoLinkBundle.my_bundles("hkhan9357@gmail.com")
		puts 'done testing permissions'
		puts my_bundles.map{|x| x.name}.join(',')
	end
	task :generate_groups => :environment do 
		members = ParseMember.limit(1000000).all.to_a
		ParseGroup.destroy_all(ParseGroup.limit(100000).where(type:'personal').to_a)
		members.each do |member|
			if member.email and member.email != ''
				ParseGroup.create(name:member.name, member_emails:[member.email], type:'personal')
			end
		end
		# committees = ['CS', 'CO', 'FI', 'MK', 'HT', 'PB', 'PD', 'SO', 'WD', 'EX', 'IN']
		# committees.each do |committee|
		# 	gname = committee + ' Fall 2015'
		# 	emails = members.select{|x| x.committee == committee}.map{|x| x.email}
		# 	ParseGroup.create(member_emails: emails, name: gname)
		# end
	end
end
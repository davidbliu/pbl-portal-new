class ArchivedMember < ParseResource::Base
	fields :name, :provider, :uid, :google_id, :profile, :member_id, :remember_token, :email, :phone, :major


	def self.migrate
		archived = Array.new
		Member.all.each do |m|
			""" people that never attended events will be archived """
			ems = EventMember.where(member_id: m.id)
			if ems.length == 0
				# puts m.to_yaml
				puts m.name
				am = ArchivedMember.new
				am.name = m.name
				am.provider = m.provider
				am.uid = m.uid
				am.google_id = m.uid
				am.profile = m.profile
				am.member_id = m.id
				am.remember_token  = m.remember_token
				am.email = m.email
				am.phone = m.phone
				am.major = m.major
				archived << am
			end
		end 
		ArchivedMember.save_all(archived)
	end

	def self.delete_archived
		""" removes archived members from ParseMember """
		archived_ids = ArchivedMember.limit(10000).all.map{|x| x.member_id}
		archived = Array.new
		puts 'these are archived ids '+archived_ids.length.to_s
		ParseMember.limit(10000).all.each do |m|
			if archived_ids.include?(m.old_id)
				puts 'deleting ' + m.name
				archived << m
			end
		end
		puts 'destroying archived '+archived.length.to_s
		ParseMember.destroy_all(archived)
	end
 end

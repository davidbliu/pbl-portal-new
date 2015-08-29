class ParseEventMember < ParseResource::Base
	fields :event_id, :member_email, :type
	# should add fields for member approval of event attendance and for chair approval

	def self.hash(ems)
		event_members = Hash.new
		ems.each do |em|
			key = em.event_id + "," + em.member_email
			event_members[key] = em
		end
		return event_members
	end

	def self.get_status(event, member, hash)
		# return 'none'
		key = event.google_id + ',' + member.email
		if hash.keys.include?(key)
			return hash[key].type
		end
		return 'none'

	end

	# worry about migrating after all e
	def self.migrate
		puts 'we will migrate past event members into the new system no the other way around'
	end
end
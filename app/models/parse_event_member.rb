class ParseEventMember < ParseResource::Base
	fields :event_id, :member_email
	# should add fields for member approval of event attendance and for chair approval


	# worry about migrating after all e
	def self.migrate
		puts 'we will migrate past event members into the new system no the other way around'
	end
end
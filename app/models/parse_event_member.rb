class ParseEventMember < ParseResource::Base
	fields :event_id, :member_id, :member_email
	# should add fields for member approval of event attendance and for chair approval


	# worry about migrating after all e
	def self.migrate
		EventMember.each do |em|
		end
	end
end
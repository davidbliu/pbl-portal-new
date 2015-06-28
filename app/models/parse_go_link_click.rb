class ParseGoLinkClick < ParseResource::Base

	fields :key, :member_id, :time

	# -1 member id for not logged in
	def self.migrate_from_old
		link_hash = ParseGoLink.hash
		old_link_hash = ParseGoLink.all.index_by(&:old_id)
		clicks = Array.new
		GoLinkClick.all.each do |glc|
			click = ParseGoLinkClick.new
			click.key = old_link_hash[glc.go_link_id].key
			puts key
			click.member_id = glc.member_id
			click.time = glc.created_at
			# clicks << click
			click.save
		end
		# ParseGoLinkClick.save_all(clicks)
	end
end

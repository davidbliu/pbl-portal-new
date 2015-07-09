class ParseGoLinkClick < ParseResource::Base

	fields :key, :member_id, :time, :old_member_id, :member_email


	def time_string
		self.time.strftime("%b %e, %Y at %l:%M %p")
	end
	def self.num_click_hash
		""" keys are alias and num clicks is the number of times clicked """
		chash = Hash.new
		ParseGoLinkClick.all.each do |click|
			key = click.key
			if not chash.keys.include?(key)
				chash[key] = 0
			end
			chash[key] += 1
		end
		return chash
	end
""" migrate clicks from old click tracking system """
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

	def self.copy_old_member_id
		clicks = Array.new
		ParseGoLinkClick.limit(100000).all.each do |click|
			puts click.key
			click.old_member_id = click.member_id
			clicks << click
		end
		ParseGoLinkClick.save_all(clicks)
	end

	def self.migrate_member_id
		old_mhash = ParseMember.old_hash 
		clicks = Array.new
		ParseGoLinkClick.limit(100000).all.each do |click|
			puts click.key
			begin
				puts old_mhash[click.old_member_id].name
				click.member_id = old_mhash[click.old_member_id].id
				clicks << click
			rescue
				puts 'problem with '+click.old_member_id.to_s
			end
		end
		ParseGoLinkClick.save_all(clicks)
	end

end

class ParseGoLinkClick < ParseResource::Base

	fields :key, :golink_id, :time, :member_email

	def self.histogram
		# keys are ids, values are num clicks
		hist = Hash.new
		ParseGoLinkClick.limit(100000).all.each do |click|
			if click.golink_id and click.golink_id != '' and not hist.keys.include?(click.golink_id)
				hist[click.golink_id] = 0
			end
			if click.golink_id and click.golink_id != ''
				hist[click.golink_id] += 1
			end
		end
		return hist
	end

	def self.hash
		h = Hash.new
		ParseGoLinkClick.limit(100000).all.each do |click|
			if click.golink_id and click.golink_id != '' and not h.keys.include?(click.golink_id)
				h[click.golink_id] = Array.new
			end
			if click.golink_id and click.golink_id != ''
				h[click.golink_id] << click
			end
		end
		return h
	end

	def get_time
		self.time. + Time.zone_offset("PDT")
	end
	def time_string
		self.get_time.strftime("%b %e, %Y at %l:%M %p")
	end

	def self.click_hash 
		chash = Hash.new
		ParseGoLinkClick.limit(10000000).all.each do |click|
			key = click.key
			if not chash.keys.include?(key)
				chash[key] = Array.new
			end
			chash[key] << click
		end
		return chash
	end

	def self.num_click_hash
		""" keys are alias and num clicks is the number of times clicked """
		chash = Hash.new
		ParseGoLinkClick.limit(10000000).all.each do |click|
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

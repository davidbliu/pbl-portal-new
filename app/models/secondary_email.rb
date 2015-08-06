class SecondaryEmail < ParseResource::Base
	fields :email, :primary_email, :data

	def self.email_lookup_hash
		h = Rails.cache.read('email_lookup_hash')
		if h != nil
			return h
		end
		self.cache_email_lookup_hash
		h = Rails.cache.read('email_lookup_hash')
		return h
	end

	def self.valid_emails
		v = Rails.cache.read('valid_emails')
		if v!= nil
			return v
		end
		self.cache_email_lookup_hash
		v = Rails.cache.read('valid_emails')
		return v
	end
	def self.cache_email_lookup_hash
		h = ParseMember.limit(100000).all.index_by(&:email)
		# also add secondary 
		secondary = SecondaryEmail.limit(1000000).all.to_a
		included_emails = Set.new(h.keys)
		secondary.each do |s|
			if not included_emails.include?(s.email) and included_emails.include?(s.primary_email)
				h[s.email] = h[s.primary_email]
				included_emails.add(s.email)
			end
		end
		Rails.cache.write('email_lookup_hash', h)
		Rails.cache.write('valid_emails', h.keys)
		return true
	end
end
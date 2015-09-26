class SecondaryEmail < ParseResource::Base
	fields :email, :primary_email, :data

	def self.email_lookup_hash
		h = Rails.cache.read('email_lookup_hash')
		if h != nil
			return h
		end
		self.cache_accounts
		h = Rails.cache.read('email_lookup_hash')
		return h
	end

	def self.json_email_lookup_hash
		Rails.cache.fetch 'json_email_lookup_hash' do 
			h = Hash.new
			lookup_hash = self.email_lookup_hash
			lookup_hash.keys.each do |email|
				h[email] = lookup_hash[email].to_json
			end
			Rails.cache.write('json_email_lookup_hash', h)
			return h
		end
	end

	def self.valid_emails
		v = Rails.cache.read('valid_emails')
		if v!= nil
			return v
		end
		self.cache_accounts
		v = Rails.cache.read('valid_emails')
		return v
	end

	def self.email_resolve_hash
		h = Rails.cache.read('email_resolve_hash')
		if h != nil
			return h
		end
		self.cache_accounts
		h = Rails.cache.read('email_resolve_hash')
		return h
	end

	def self.cache_accounts
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
		# get email resolve hash
		email_resolve_hash = Hash.new
		secondary.each do |secondary|
			primary = secondary.primary_email
			if not email_resolve_hash.keys.include?(primary)
				email_resolve_hash[primary] = Array.new
			end
			email_resolve_hash[primary] << secondary.email
		end
		secondary.each do |secondary|
			email_resolve_hash[secondary.email] = email_resolve_hash[secondary.primary_email]
		end
		Rails.cache.write('email_resolve_hash', email_resolve_hash)
		Rails.cache.write('email_lookup_hash', h)
		Rails.cache.write('valid_emails', h.keys)
		return true
	end
end
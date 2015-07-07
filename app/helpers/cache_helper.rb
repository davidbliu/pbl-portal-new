module CacheHelper

	""" semester caching methods """

	""" member caching methods """
	def current_members
		ParseMember.current_members
	end

	def member_email_hash
		a = Rails.cache.read('member_email_hash')
		if a != nil
			return a
		end
		a = ParseMember.limit(10000).all.index_by(&:email)
		Rails.cache.write('member_email_hash', a)
		return a
	end

	""" tabling caching methods """

	""" points caching methods """

	""" go key caching methods """
	def clear_go_cache
		Rails.cache.write("go_link_hash", nil)
		Rails.cache.write("go_link_key_hash", nil)
	end

	def go_link_key_hash
		a = Rails.cache.read('go_link_key_hash')
		if a != nil
			return a
		end
		a = ParseGoLink.limit(10000).all.index_by(&:key)
		Rails.cache.write('go_link_key_hash', a)
		return a
	end

	def go_link_hash
		a = Rails.cache.read('go_link_hash')
		if a != nil
			return a
		end
		a = ParseGoLink.limit(10000).all.index_by(&:id)
		Rails.cache.write('go_link_hash', a)
		return a
	end
end

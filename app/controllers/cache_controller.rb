class CacheController < ApplicationController


	def cache_golinks
		ParseGoLink.cache_golinks
		render nothing:true, status:200
	end

	def cache_groups
		ParseGroup.cache_groups
		render nothing:true, status:200
	end

	def cache_members
	end
end
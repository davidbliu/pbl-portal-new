require 'will_paginate/array'
class ApiController < ApplicationController
	MAXINT = (2**(0.size * 8 -2) -1)
	def all_golinks
		sort_by = 'createdAt desc'
		page = params[:page] ? params[:page] : 1
		@golinks = ParseGoLink.all_golinks
		render json: @golinks.paginate(:page => page, :per_page => 100)
	end

	def recent_clicks
		render json: ParseGoLinkClick.limit(1000).to_a
	end
end
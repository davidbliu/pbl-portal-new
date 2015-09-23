require 'will_paginate/array'
class ApiController < ApplicationController
	MAXINT = (2**(0.size * 8 -2) -1)
	before_filter :cors_preflight_check
	after_filter :cors_set_access_control_headers

	def cors_set_access_control_headers
		headers['Access-Control-Allow-Origin'] = '*'
		headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
		headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
		headers['Access-Control-Max-Age'] = "1728000"
	end

	def cors_preflight_check
		if request.method == 'OPTIONS'
			headers['Access-Control-Allow-Origin'] = '*'
			headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
			headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
			headers['Access-Control-Max-Age'] = '1728000'

			render :text => '', :content_type => 'text/plain'
		end
	end

	
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
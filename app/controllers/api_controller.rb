require 'will_paginate/array'
class ApiController < ApplicationController
	MAXINT = (2**(0.size * 8 -2) -1)
	before_filter :cors_preflight_check
	after_filter :cors_set_access_control_headers

	# davids token is 6461766964626c697540676d61696c2e636f6d
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

	def get_email_from_token(token)
		if not token
			return nil
		end
		s = token.scan(/../).map { |x| x.hex.chr }.join
		return s
	end

	def all_golinks
		sort_by = 'createdAt desc'
		email = get_email_from_token(params[:token])
		puts 'email was '+email.to_s
		page = params[:page] ? params[:page] : 1
		if not email
			render json: []
		else
			@golinks = GoLink.order("created_at desc").all.paginate(:page=>page, :per_page=>100).map{|x| x.to_parse}.select{|x| x.can_view(SecondaryEmail.email_lookup_hash[email])}
			# to json
			@golinks = @golinks.map{|x| x.to_json}
			render json: @golinks # @golinks.paginate(:page => page, :per_page => 100)
		end
	end

	def search_golinks
		search_term = params[:search_term]
		email = get_email_from_token(params[:token])
		page = params[:page] ? params[:page] : 1
		@golinks = ParseGoLink.search(search_term)
		@golinks = @golinks.select{|x| x.can_view(SecondaryEmail.email_lookup_hash[email])}.map{|x| x.to_json}
		render json: @golinks.paginate(:page => page, :per_page => 100)
	end

	def recent_clicks
		render json: ParseGoLinkClick.order("time desc").limit(1000).to_a
	end

	def user_clicks
		if not params[:email] or params[:email] == ''
			render json: []
		else
			render json: ParseGoLinkClick.order('time desc').where(member_email: params[:email]).to_a
		end
	end	
	# main users based on last 10000 clicks
	def main_users
		@main_users = ParseGoLink.main_users
		render json: @main_users
	end

	def save_golink
		key = params[:key]
		description = params[:description]
		tags = params[:tags].split(",")
		url = params[:url]
		id = params[:id]
		permissions = params[:permissions]
		puts key
		puts id
		puts description
		puts url
		puts tags.to_s
		puts permissions

		golink = ParseGoLink.find(id)
		golink.description = description
		golink.tags = tags.select{|x| x != '' }
		golink.key = key 
		golink.url = url
		golink.permissions = permissions
		# reflect changes in GoLink so appears in search
		gl = GoLink.where(parse_id:golink.id)
		if gl.length > 0
			gl = gl.first
			gl.description = description
			gl.tags = Array.new(tags)
			gl.url = url
			gl.key = key
			gl.permissions = permissions
			gl.save
		end
		golink.save
		render nothing:true, status:200

	end
end
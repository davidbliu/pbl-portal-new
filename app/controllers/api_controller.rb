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

	def send_push
		recipients = params[:recipients]
		message = params[:message]
		links = params[:links]
		email = params[:email]
		recipients = Set.new(recipients).to_a
		Share.create(sender: email, recipient: 'old', message: message, links: links, time:Time.now, message_id: SecureRandom.hex.to_s, all_recipients: recipients.join(','))
		recipients << email
		message = NotificationClient.push(current_member, recipients, 'PBL Link Notifier',  message, links)
		render json: message
	end
	def golink_clicks
		key = params[:key]
		clicks = ParseGoLinkClick.limit(1000).order('createdAt desc').where(key: key).to_a
		clicks = clicks.map{|x| {'email'=> x.member_email, 'time'=>x.time_string, 'timestamp'=>x.timestamp}}
		render json: clicks
	end

	def get_link_post
		search_term = params[:search_term]
		post = PgPost.where(title: search_term)
		if post.length == 0
			puts 'no post for that resutl'
			render nothing: true, status:200
		else
			puts 'found post'
			puts post.first.content
			render json: {'content'=>post.first.content}
		end
	end

	def top_recent
		email = get_email_from_token(params[:token])
		@results = GoStat.top_recent
		render json: @results
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

	def recent_golinks
		email = get_email_from_token(params[:token])
		@golinks = ParseGoLink.order('createdAt desc').all.select{|x| x.can_view(SecondaryEmail.email_lookup_hash[email])}
		@golinks = @golinks.map{|x| x.to_json}
		render json: @golinks
	end

	def search_golinks
		search_term = params[:search_term]
		email = get_email_from_token(params[:token])
		page = params[:page] ? params[:page] : 1
		# if tag search
		if search_term.include?('#')
			@golinks = ParseGoLink.tag_search(search_term.gsub('#', ''))
		else
		# if regular search
			@golinks = ParseGoLink.search(search_term)
		end
		@golinks = @golinks.select{|x| x.can_view(SecondaryEmail.email_lookup_hash[email])}.map{|x| x.to_json}
		render json: @golinks.paginate(:page => page, :per_page => 100)
	end

	def popular_golinks
		email = get_email_from_token(params[:token])
		@golinks = ParseGoLink.order("num_clicks desc").select{|x| x.can_view(SecondaryEmail.email_lookup_hash[email])}
		@golinks = @golinks.map{|x| x.to_json}
		render json: @golinks	
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

	def add_golink
		key = params[:key]
		url = params[:url]
		email = params[:email]
		golink = ParseGoLink.create(url:url, key: key, permissions:'Anyone', member_email:email)
		# reflect changes in GoLink so appears in search
		gl = GoLink.new(key: key, member_email: email, permissions: 'Anyone', url: url)
		gl.parse_id = golink.id
		gl.save
		render nothing:true, status:200
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
	def delete_golink
		ParseGoLink.find(params[:id]).destroy
		GoLink.destroy_all(parse_id: params[:id])
		render nothing:true, status:200
	end

	""" golink users """
	def contributors
		render json: GoStat.contributors
	end

	def contributions
		email = params[:email]
		token = params[:token]
		my_email = get_email_from_token(token)
		contributions = ParseGoLink.limit(1000).order('createdAt desc').where(member_email: email).to_a
		contributions = contributions.select{|x| x.can_view(SecondaryEmail.email_lookup_hash[my_email])}
		contributions = contributions.map{|x| x.to_json}
		render json: contributions
	end


	""" Members API Routes"""
	def current_members
		render json: ParseMember.current_members.map{|x| x.to_json}
	end
	# def committee_hash
		# render 
	# end
end
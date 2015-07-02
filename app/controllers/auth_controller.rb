class AuthController < ApplicationController
	def index
		
	end

	def google_callback
		result = Hash.new
		authentication_info = request.env["omniauth.auth"]
		
		cookies[:access_token] = authentication_info["credentials"]["token"]
		cookies[:refresh_token] = authentication_info["credentials"]["refresh_token"]
		
		provider = authentication_info['provider']
		uid = authentication_info['uid']
		email = authentication_info['info']['email']

		cookies[:uid] = uid
		cookies[:provider] = provider
		cookies[:email] = email
		#added by david (save the uid so upon new member creation can be used)
		member = ParseMember.where(email: email) #.where(provider: provider, uid: uid)
		if member.length > 0
			member = member.first
			result['member_name'] = member.name
			cookies[:remember_token] = member.remember_token
			redirect_to root_path
		else
			redirect_to :controller=>'auth',:action=>'sign_up'
		end
	end


	def sign_up

	end


end
class AuthController < ApplicationController
	def index
		
	end

	def google_callback
		puts 'callback is starting'
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
			# cookies[:remember_token] = member.remember_token
			cookies[:remember_token] = member.email
			redirect_to root_path
		else
			redirect_to :controller=>'auth',:action=>'sign_up', :email => email
		end
	end

	def sign_out
		cookies[:remember_token] = nil
	    current_member = nil
	    redirect_to "https://accounts.google.com/logout"
	end

	def sign_up
		@email = params[:email]
		""" there is no way for a member to sign up themselves, they need to be authenticated through the secretary """ 

		""" accounts will be auto-created from a spreadsheet at the beginning of the semester, we do not want to let people dynamically sign up""" 
	end


end
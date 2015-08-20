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
		member = nil
		if SecondaryEmail.valid_emails.include?(email)
			member = SecondaryEmail.email_lookup_hash[email]
		end
		if member != nil
			result['member_name'] = member.name
			cookies[:remember_token] = member.email
			redirect_to root_path
		else
			@email = email
			render no_account, layout:false
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
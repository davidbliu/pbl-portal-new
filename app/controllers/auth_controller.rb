class AuthController < ApplicationController
	def index
		
	end

	def sign_in
		return 'signing in'
	end


	#
	# callback method when hits /auth/google_oauth2/callback
	#
	def google_callback
		p 'callback method'
		# redirect to the homepage
		redirect_to ""
	end

end
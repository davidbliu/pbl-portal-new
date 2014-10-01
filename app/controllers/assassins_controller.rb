class AssassinsController < ApplicationController
	def index
		if not current_member
			render json: 'you are not logged in you cant play assassins'
			return
		end
		@assassins_address = 'portal.berkeley-pbl.com:3001'
		@route = @assassins_address+'/view_assignment/'+current_member.uid
	end
end

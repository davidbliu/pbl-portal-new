class WdController < ApplicationController

	def david
		@members = ParseMember.current_members.map{|x| x.name}.select{|x| x.downcase.include?('eric')}
		render 'david', layout: false
	end
	
	def jason
		@points = PointManager.get_points('davidbliu@gmail.com')
		render 'jason'
	end
end

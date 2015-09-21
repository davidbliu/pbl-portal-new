class WdController < ApplicationController

	def david
		@members = ParseMember.current_members.map{|x| x.name}.select{|x| x.downcase.include?('eric')}
		render 'david', layout: false
	end
	
	def jason
		@points = PointManager.get_points('davidbliu@gmail.com')
		render 'jason'
	end

	def kimberly
		@my_email = current_member.email
		@current_members = ParseMember.current_members
		@current_emails = @current_members.map{|x| x.email}
		@member_emails = SecondaryEmail.email_lookup_hash.keys
		@member_email_hash = SecondaryEmail.email_lookup_hash
		render 'kimberly'
	end

	def eric
		@committee_hash = ParseMember.committee_hash
		@current_member = current_member
	end
end

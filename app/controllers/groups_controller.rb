class GroupsController < ApplicationController

	def view_group
		@group = ParseGroup.find(params[:id])

	end

	def view_groups
		@groups = ParseGroup.limit(10000).all.to_a
		@member_email_hash = member_email_hash
	end


end
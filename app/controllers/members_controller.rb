class MembersController < ApplicationController
	def test
		# 
		# test all member functions
		# 
		me = Member.where(name: "David Liu").first
		# p me.committees
		# p me.primary_committee
		# p me.current_committee
		# p Member.current_members
		# p me.position
		# p me.tier
	end

	def index
		@current_members = Member.current_members
		# @current_members = Member.all
	end
end
class GoLinkClicksController < ApplicationController
	def index
		@go_link_clicks = GoLinkClick.where("member_id IS NOT NULL AND go_link_id IS NOT NULL")
		@member_hash = Member.member_hash
		@member_hash[-1] = Member.new(name: "Not Logged In")
		@go_link_id_hash = GoLink.go_link_id_hash
	end
end
class GoLinkClicksController < ApplicationController
	def index
		@go_link_clicks = GoLinkClick.where("member_id IS NOT NULL AND go_link_id IS NOT NULL")
	end
end
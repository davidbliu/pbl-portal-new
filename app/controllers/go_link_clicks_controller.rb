class GoLinkClicksController < ApplicationController
	def index
		@go_link_clicks = GoLinkClick.where("member_id IS NOT NULL AND go_link_id IS NOT NULL")
		@member_hash = Member.member_hash
		@member_hash[-1] = Member.new(name: "Not Logged In")
		@go_link_id_hash = GoLink.go_link_id_hash

		@link_clicks_hash = Hash.new
		@go_link_clicks.each do |click|
			if not @link_clicks_hash.keys.include?(click.go_link_id)
				@link_clicks_hash[click.go_link_id] = Hash.new
			end
			if not @link_clicks_hash[click.go_link_id].keys.include?(click.member_id)
				@link_clicks_hash[click.go_link_id][click.member_id] = Array.new
			end
			@link_clicks_hash[click.go_link_id][click.member_id] << click
		end
		render 'index.html.erb', layout: false
	end
end
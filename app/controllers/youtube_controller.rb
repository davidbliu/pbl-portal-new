require 'google/api_client'
require 'json'

class YoutubeController < ApplicationController

#
	def index
		@videos = Video.all
	end


	def sync
		Video.destroy_all
		#
		# authenticate with youtube
		#
		dev_key = "AIzaSyCbVjHcjFjWxThf4ajuOVMTLXPqTbPXjAM"
		client = YouTubeIt::Client.new(:username=>"chriswong@berkeley.edu", :password=>"ruleofthirds", :dev_key => dev_key)
		all_videos = Array.new
		begin
			page = 1
			videos = client.my_videos(:page => page, :per_page => 50).videos
			while videos.length > 0
				all_videos = all_videos + videos
				page = page + 1
				videos = client.my_videos(:page => page, :per_page => 50).videos
				p 'getting more videos, current video count is'
				p all_videos.length
			end
		rescue Exception => e
			p e
			render json: "there was an error"
			return
		end
		all_videos.each do |yvid|
			Video.insert_new_video(yvid)
		end
		render json: 'these many videos were synced '+Video.count.to_s
	end
end

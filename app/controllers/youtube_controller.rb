require 'google/api_client'
require 'json'

class YoutubeController < ApplicationController

#
	def index
		@videos = Video.all
	end

	def get_youtube_sync_text
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
		render json: all_videos.to_json
	end


	def text_sync

	end

	def process_text_sync
		Video.destroy_all
		require 'json'
		videos_string = params[:yt_text]
		videos = JSON.parse(videos_string)
		videos.each do |video|
			Video.insert_new_text_video(video)
			"inserted "+video["title"]
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
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

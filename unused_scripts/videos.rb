require 'youtube_it'
require 'json'

def get_playlists(account, password)
	dev_key = "AIzaSyCbVjHcjFjWxThf4ajuOVMTLXPqTbPXjAM"

	client = YouTubeIt::Client.new(:username=>account, :password=>password, :dev_key => dev_key)
	playlists = client.playlists()
	p playlists
	playlists.all.each do |playlist|
		p playlist.title
		# p playlist.videos
		# playlist.videos(:page => page, :per_page => 50).videos.each do |video|
		# 	p '\t'+video.title
		# end
	end
end

def sync_videos(account, password)

	dev_key = "AIzaSyCbVjHcjFjWxThf4ajuOVMTLXPqTbPXjAM"

	client = YouTubeIt::Client.new(:username=>account, :password=>password, :dev_key => dev_key)
	all_videos = Array.new
	begin
		page = 1
		videos = client.my_videos(:page => page, :per_page => 50).videos
		while videos.length > 0
			all_videos = all_videos + videos
			page = page + 1
			videos = client.my_videos(:page => page, :per_page => 50).videos
			p 'getting more videos, current video count is '+all_videos.length.to_s
		end

	rescue Exception => e
		p e
		render json: "there was an error"
		return
	end

	min_json = Array.new
	all_videos.each do |video|
		min_video = Hash.new
		min_video["title"]=video.title
		min_video["unique_id"]=video.unique_id
		min_video["uploaded_at"]=video.uploaded_at
		min_video["playlist"] = "not implemented yet"
		min_json << min_video
	end
	File.open("youtube_sync_text.json", 'w') { |file| file.write(all_videos[0].inspect.to_json) }
end
#
# resolve tags from name
#
def resolve_tags_from_string(tagstring)
	tags = tagstring.scan(/\[(.*?)\]/)
	tags.each do |tag|
		tagstring.slice!("["+tag[0]+"]")
		p tag
	end
	stripped_name = tagstring

	result = Hash.new
	result["title"] = stripped_name
	result["tags"] = tags.map{|tag| tag[0]}
	return result
end


# tagstring = "[IN][PB] Apprentice Challenge"
# p 'scanning tagstring'
# p resolve_tags_from_string(tagstring)
print 'hello master Liu'
account  = "chriswong@berkeley.edu"
password = "ruleofthirds"
get_playlists(account, password)
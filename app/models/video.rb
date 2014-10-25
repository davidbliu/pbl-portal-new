class Video < ActiveRecord::Base
	has_many :video_tags
	has_many :tags, through: :video_tags
	has_many :playlist_videos
	has_many :playlists, :through => :playlist_videos
	#
	# unnused
	#
	def self.insert_new_video(video)
		p 'the unique id was '+video.unique_id.to_s
		new_video = Video.new
		new_video.youtube_id = video.unique_id
		new_video.uploaded_at = video.uploaded_at
		new_video.title = video.title
		new_video.save
	end

	#
	# insert a new video from hash of values
	#
	def self.insert_new_text_video(video)
		# p 'the unique id was '+video.unique_id.to_s
		new_video = Video.new
		new_video.youtube_id = video["unique_id"]
		new_video.uploaded_at = video["uploaded_at"]
		new_video.title = video["title"]
		playlist_name = video["playlist"]
		playlist = Playlist.where(name: playlist_name)
		#
		# create new playlist if necessary
		#
		if playlist.length < 1
			# create a new playlist
			plist = Playlist.new
			plist.name = playlist_name
			plist.save
		end
		playlist = Playlist.where(name: playlist_name)
		playlist = playlist.first
		p playlist.name
		p 'that was the playlists name'
		playlist.videos << new_video
		new_video.save
	end

	def self.resolve_tags
		p 'resolving tags!'
		Video.all.each do |video|
		title_data = video.resolve_tags_from_string
			if title_data["tags"].length == 0
				title_data["tags"] << "Untagged"
			end
			title_data["tags"].each do |tagname|
				if Tag.where(name: tagname).length < 1
					# tag doesnt exist yet
					newtag = video.tags.new
					newtag.name = tagname
					newtag.save
				end
				tag = Tag.where(name:tagname).first
				# insert into jointable
				join = VideoTag.where(video_id: video.id).where(tag_id: tag.id).first_or_create
				join.save
			end
		end
		p Tag.all
		p 'there are '+Tag.all.length.to_s+" tags"
	end
	# 
	# from a video title, get its tags
	# 
	def resolve_tags_from_string
		tagstring = self.title
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

	#
	# return a list of my tags
	#
	def get_tags
	end

	#
	# generate tags for all videos
	# this method will reset all your tags!
	#
	def self.resolve_tags

	end
end

class Video < ActiveRecord::Base

	def self.insert_new_video(video)
		p 'the unique id was '+video.unique_id.to_s
		new_video = Video.new
		new_video.youtube_id = video.unique_id
		new_video.uploaded_at = video.uploaded_at
		new_video.title = video.title
		new_video.save
	end


end

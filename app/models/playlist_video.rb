class PlaylistVideo < ActiveRecord::Base
	  attr_accessible :playlist_id, :video_id
	  belongs_to :playlist 
	  belongs_to :video
end

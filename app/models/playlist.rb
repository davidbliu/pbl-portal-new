class Playlist < ActiveRecord::Base
	attr_accessible :name, :priority
	has_many :playlist_videos
	has_many :videos, :through => :playlist_videos
end

class VideoTag < ActiveRecord::Base
	belongs_to :video
	belongs_to :tag
end

class Tag < ActiveRecord::Base
	has_many :video_tags
	has_many :videos, through: :video_tags

end

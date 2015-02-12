class ScavengerTheme < ActiveRecord::Base
	attr_accessible :name, :start_time, :end_time, :description

	has_many :scavenger_photos
end

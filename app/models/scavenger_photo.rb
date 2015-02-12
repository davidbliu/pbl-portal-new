class ScavengerPhoto < ActiveRecord::Base
	attr_accessible :name, :description, :image, :scavenger_theme_id, :member_id

	belongs_to :scavenger_theme
end

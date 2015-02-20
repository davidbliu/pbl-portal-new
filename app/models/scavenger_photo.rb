class ScavengerPhoto < ActiveRecord::Base
	attr_accessible :name, :description, :image, :scavenger_theme_id, :member_id, :group_id, :confirmation_status

	belongs_to :scavenger_theme
end

class ScavengerGroup < ActiveRecord::Base
	attr_accessible :name, :scavenger_theme_id

	belongs_to :scavenger_theme_id
end
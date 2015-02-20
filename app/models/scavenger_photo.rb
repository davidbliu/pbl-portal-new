class ScavengerPhoto < ActiveRecord::Base
	attr_accessible :name, :description, :image, :scavenger_theme_id, :member_id, :group_id, :points,:confirmation_status

	belongs_to :scavenger_theme

	def group
		return ScavengerGroup.find(self.group_id)
	end

	def lateness
		due = self.theme.end_time
		return due-self.created_at
	end

	def theme
		return ScavengerTheme.find(self.group.scavenger_theme_id)
	end
end

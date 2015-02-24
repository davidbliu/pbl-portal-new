class ScavengerPhoto < ActiveRecord::Base
	attr_accessible :name, :description, :image, :scavenger_theme_id, :member_id, :group_id, :points,:confirmation_status

	belongs_to :scavenger_theme
	# belongs_to :scavenger_group, :foreign_key=>:group_id, :dependent=>:destroy

	def group
		return ScavengerGroup.find(self.group_id)
	end

	def lateness
		due = self.theme.end_time.to_datetime
		diff = (self.created_at.to_datetime-due)
		times = Hash.new
		times['minutes'] = (diff * 24 * 60).floor % 60
		times['hours'] = (diff*24).floor % 24
		times['days'] = diff.floor

		return times
	end


	def theme
		return ScavengerTheme.find(self.group.scavenger_theme_id)
	end
end

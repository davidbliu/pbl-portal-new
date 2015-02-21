class ScavengerGroupMember < ActiveRecord::Base
	attr_accessible :member_id, :scavenger_groups_id

	belongs_to :scavenger_group 

	def group
		return ScavengerGroup.find(self.scavenger_groups_id)
	end
end
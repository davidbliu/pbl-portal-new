class ScavengerGroup < ActiveRecord::Base
	attr_accessible :name, :scavenger_theme_id

	belongs_to :scavenger_theme

	def get_members
		group_members = ScavengerGroupMember.where(scavenger_groups_id: self.id).pluck(:member_id)
		return Member.where('id in (?)', group_members)
	end

	def self.get_groups(member_id)
		group_member_ids = ScavengerGroupMember.where(member_id: member_id).pluck(:scavenger_groups_id)
		groups = ScavengerGroup.where('id in (?)', group_member_ids)
	end

end
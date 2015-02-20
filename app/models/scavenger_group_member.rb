class ScavengerGroupMember < ActiveRecord::Base
	attr_accessible :member_id, :scavenger_groups_id

	belongs_to :scavenger_group 
end
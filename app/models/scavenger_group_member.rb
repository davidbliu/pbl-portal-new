class ScavengerGroupMember < ActiveRecord::Base
	attr_accessible :member_id, :group_id

	belongs_to
class ScavengerTheme < ActiveRecord::Base
	attr_accessible :name, :start_time, :end_time, :description, :points, :late_points

	has_many :scavenger_photos

	# this will delete current groups if there are any
	def generate_groups
		ScavengerGroup.where(scavenger_theme_id: self.id).destroy_all
		p 'generating groups'
		people = Member.current_cms.to_a
		num_groups = (people.length / 5).floor

		extra = people.length % 5


		#temp array of reordered people
		people = people.shuffle

		# create groups
		for i in 0..num_groups-extra-1
			group = ScavengerGroup.new
			group.scavenger_theme_id = self.id
			group.name = 'group'+Random.rand(1000000).to_s
			# add people to group
			group_people = people[0, 5]
			people  =people[5, people.length]
			group.save!
			for p in group_people
				gm = ScavengerGroupMember.new
				gm.member_id = p.id
				gm.scavenger_groups_id = group.id
				gm.save!
			end
		end
		#odd group
		if extra != 0
			for i in 0..extra-1
				group = ScavengerGroup.new
				group.scavenger_theme_id = self.id
				group.name = 'group'+Random.rand(1000000).to_s
				# add people to group
				group_people = people[0, 6]
				people  =people[6, people.length]
				group.save!
				for p in group_people
					gm = ScavengerGroupMember.new
					gm.member_id = p.id
					gm.scavenger_groups_id = group.id
					gm.save!
				end
			end
			

		end
	end

	def get_groups
		return ScavengerGroup.where(scavenger_theme_id: self.id)
	end
end

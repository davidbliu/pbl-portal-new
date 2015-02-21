class ScavengerTheme < ActiveRecord::Base
	attr_accessible :name, :start_time, :end_time, :description, :points, :late_points

	has_many :scavenger_photos

	def get_photos
		group_ids = ScavengerGroup.where(scavenger_theme_id: self.id).pluck(:id)
		return ScavengerPhoto.where('group_id in (?)', group_ids)
	end
	# this will delete current groups if there are any
	def generate_groups
		ScavengerGroup.where(scavenger_theme_id: self.id).destroy_all
		p 'generating groups'
		people = Member.current_cms.to_a + Member.current_chairs.to_a
		people = people.shuffle
		num_groups = (people.length / 5).floor

		extra = people.length % 5


		#temp array of reordered people
		people = people.shuffle

		# create groups
		for i in 0..num_groups-extra-1
			group = ScavengerGroup.new
			group.scavenger_theme_id = self.id
			# group.name = 'group'+Random.rand(1000000).to_s
			group.name = ScavengerTheme.generate_group_name
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
	def groups
		return ScavengerGroup.where(scavenger_theme_id: self.id)
	end
	def get_group(member_id)
		group_ids = self.get_groups.pluck(:id)
		group_members = ScavengerGroupMember.where("scavenger_groups_id in (?)", group_ids).where(member_id: member_id)
		if group_members.length>0
			return group_members.first.group
		else
			return nil
		end
	end

	def time_till_due
		start_time = DateTime.now
		end_time = self.end_time

		# elapsed_seconds = ((end_time - start_time) * 24 * 60 * 60).to_i
		diff = (self.end_time.to_datetime-DateTime.now)
		times = Hash.new
		times['minutes'] = (diff * 24 * 60).floor % 60
		times['hours'] = (diff*24).floor % 24
		times['days'] = diff.floor

		return times

	end
	def self.generate_group_name
		left = ["admiring",
		"adoring",
		"agitated",
		"angry",
		"backstabbing",
		"berserk",
		"boring",
		"clever",
		"cocky",
		"compassionate",
		"condescending",
		"cranky",
		"desperate",
		"determined",
		"distracted",
		"dreamy",
		"drunk",
		"ecstatic",
		"elated",
		"elegant",
		"evil",
		"fervent",
		"focused",
		"furious",
		"gloomy",
		"goofy",
		"grave",
		"happy",
		"high",
		"hopeful",
		"hungry",
		"insane",
		"jolly",
		"jovial",
		"kickass",
		"lonely",
		"loving",
		"mad",
		"modest",
		"naughty",
		"nostalgic",
		"pensive",
		"prickly",
		"reverent",
		"romantic",
		"sad",
		"serene",
		"sharp",
		"sick",
		"silly",
		"sleepy",
		"stoic",
		"stupefied",
		"suspicious",
		"tender",
		"thirsty",
		"trusting"]
		right = ['Artichokes ', 'Asparagus ', 'Belgian Endive', 'Broccoli', 'Butter Lettuce', 'Cactus', 'Chayote Squash ', 'Chives', 'Collard Greens', 'Corn', 'Fava Beans', 'Fennel', 'Fiddlehead Ferns', 'Green Beans', 'Manoa Lettuce', 'Morel Mushrooms', 'Mustard Greens', 'Pea Pods', 'Peas', 'Purple Asparagus', 'Radicchio', 'Ramps', 'Red Leaf Lettuce', 'Rhubarb ', 'Snow Peas', 'Sorrel', 'Spinach', 'Spring Baby Lettuce', 'Swiss Chard', 'Vidalia Onions', 'Watercress', 'Acorn Squash', 'Belgian Endive', 'Black Salsify', 'Broccoli', 'Brussels Sprouts', 'Butter Lettuce', 'Buttercup Squash', 'Butternut Squash', 'Cauliflower', 'Chayote Squash', 'Chinese Long Beans', 'Delicata Squash', 'Diakon Radish', 'Endive', 'Garlic', 'Ginger', 'Jalapeno Peppers', 'Jerusalem Artichoke', 'Kohlrabi', 'Pumpkin', 'Radicchio', 'Sweet Dumpling Squash', 'Sweet Potatoes', 'Swiss Chard', 'Turnips', 'Winter Squash', 'Amaranth', 'Arrowroot', 'Banana Squash', 'Bell Peppers', 'Black Eyed Peas', 'Black Radish', 'Bok Choy', 'Broccoflower', 'Broccolini', 'Burdock Root', 'Cabbage', 'Carrots', 'Celeriac (Celery Root)', 'Celery', 'Cherry Tomatoes', 'Chinese Eggplants', 'Galangal Root', 'Leek', 'Lettuce', 'Mushrooms', 'Olives', 'Onions', 'Parsnips', 'Pearl Onions', 'Potatoes', 'Rutabagas', 'Salad Savoy', 'Snow Peas', 'Wasabi Root', 'Yucca Ro']

		# right = [
		# "albattani",
		# "almeida",
		# "archimedes",
		# "ardinghelli",
		# "babbage",
		# "banach",
		# "bardeen",
		# "brattain",
		# "shockley",
		# "bartik",
		# "bell",
		# "blackwell",
		# "bohr",
		# "brown",
		# "carson",
		# "colden",
		# "cori",
		# "curie",
		# "darwin",
		# "davinci",
		# "einstein",
		# "elion",
		# "engelbart",
		# "euclid",
		# "fermat",
		# "fermi",
		# "feynman",
		# "franklin",
		# "galileo",
		# "goldstine",
		# "goodall",
		# "hawking",
		# "heisenberg",
		# "hodgkin",
		# "hoover",
		# "hopper",
		# "hypatia",
		# "jang",
		# "jones",
		# "kirch",
		# "kowalevski",
		# "lalande",
		# "leakey",
		# "lovelace",
		# "lumiere",
		# "mayer",
		# "mccarthy",
		# "mcclintock",
		# "mclean",
		# "meitner",
		# "mestorf",
		# "morse",
		# "newton",
		# "nobel",
		# "payne",
		# "pare",
		# "pasteur",
		# "perlman",
		# "pike",
		# "poincare",
		# "poitras",
		# "ptolemy",
		# "ritchie",
		# "thompson",
		# "rosalind",
		# "sammet",
		# "sinoussi",
		# "stallman",
		# "swartz",
		# "tesla",
		# "torvalds",
		# "turing",
		# "wilson",
		# "wozniak",
		# "wright",
		# "yalow",
		# "yonath"]
		name = left.sample + ' '+right.sample
		repeats = 0
		while ScavengerGroup.where(name:name).length>0 and repeats<10
			repeats = repeats+1
			name = left.sample+' '+right.sample
		end
		return name[0].capitalize+name[1,name.length]
	end
end

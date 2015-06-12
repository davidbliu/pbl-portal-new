class CommitteeMemberPosition
	def initialize(name, abbr, tier, permissions)
		@name = name 
		@abbr = abbr
		@tier = tier
		@permissions = permissions
	end

	def name
		@name
	end

	def abbr
		@abbr
	end

	def tier
		@tier
	end

	def permissions
		@permissions
	end

	def self.positions
		positions = Hash.new
	    positions[0] = CommitteeMemberPosition.new('general member', 'gm', 0, 0)
	    positions[1] = CommitteeMemberPosition.new('committee member', 'cm', 1, 1)
	    positions[2] = CommitteeMemberPosition.new('chair', 'chair', 2, 2)
	    positions[3] = CommitteeMemberPosition.new('executive', 'ex', 3, 3)
	    return positions
	end
end
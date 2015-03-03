class Feedback < ActiveRecord::Base
	attr_accessible :member_id, :content
	def member
		return Member.find(self.member_id)
	end
end

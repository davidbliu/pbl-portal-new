class Applicant < ActiveRecord::Base
	attr_accessible :description, :image, :name, :preference1, :preference2, :preference3, :deliberation_id, :email
	belongs_to :deliberation
	has_many :applicant_rankings, :foreign_key => :applicant, dependent: :destroy
	has_many :deliberation_assignments, :foreign_key => :applicant, dependent: :destroy
	# before_save :default_preferences
	# after_save :default_rankings
	validates_format_of :email, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :on => :save
	validates_uniqueness_of :name, :scope => [:deliberation_id]

	def payment_status_text
		if not self.payment_status
			return 'no payment'
		elsif self.payment_status == 0
			return 'Missing Payment'
		elsif self.payment_status == 1
			return 'does not have to pay'
		elsif self.payment_status == 2
			return 'Paid'
		end
	end


	def first_choice_committee
		return Committee.find(self.preference1)
	end

	def second_choice_committee
		return Committee.find(self.preference2)
	end

	def third_choice_committee
		return Committee.find(self.preference3)
	end

	def fix_duplicate_preferences
		if self.preference3 == self.preference2 or self.preference3 == self.preference1
		  self.preference3 = 1
		end
		if self.preference2 == self.preference1
		  self.preference2 = 1
		end
	end
  
	def give_default_rankings
		committee1 = self.first_choice_committee
		committee2 = self.second_choice_committee
		committee3 = self.third_choice_committee
		committees = [committee1, committee2, committee3]
		for c in committees
			
			rank_query = ApplicantRanking.where(deliberation_id: self.deliberation_id).where(applicant: self.id).where(committee: c.id)
			if not rank_query.length>0
				rank = ApplicantRanking.new
				rank.committee = c
				rank.applicant = self
				rank.deliberation = self.deliberation
				rank.value = 50
				rank.save
			end
			
		end
	end

	def committee_rank(committee_id)
		deliberation = self.deliberation
		return deliberation.applicant_rankings.where(applicant:self.id).where(committee:committee_id).first
		# return ApplicantRanking.where(deliberation_id: self.deliberation_id).where(applicant: self.id).where(committee: committee_id).first.value
	end
	# def default_rankings
	# 	committee1 = Committee.find(self.preference1)
	# 	committee2 = Committee.find(self.preference2)
	# 	committee3 = Committee.find(self.preference3)
	# 	committees = [committee1, committee2, committee3]
	# 	for c in committees
	# 		# if c.name != "Executives" and c.name != "General Members"
	# 		if self.deliberation_id and ApplicantRanking.where(deliberation_id: self.deliberation_id).where(applicant: self).where(committee: c).length == 0
	# 			rank = ApplicantRanking.new
	# 			rank.committee = c.id
	# 			rank.applicant = self
	# 			rank.deliberation_id = self.deliberation_id
	# 			rank.value = 50
	# 			rank.save
	# 			self.applicant_rankings << rank
	# 		end
	# 	end
	# end

	# def default_preferences
	# 	gm_id = 1
	# 	if Committee.where(id: self.preference1).length == 0
	# 		self.preference1 = gm_id
	# 	end
	# 	if Committee.where(id: self.preference2).length == 0
	# 		self.preference2 = gm_id
	# 	end
	# 	if Committee.where(id: self.preference3).length == 0
	# 		self.preference3 = gm_id
	# 	end
	# end
end

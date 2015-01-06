class Applicant < ActiveRecord::Base
  attr_accessible :description, :image, :name, :preference1, :preference2, :preference3, :deliberation_id, :email
  belongs_to :deliberation
  has_many :applicant_rankings, :foreign_key => :applicant, dependent: :destroy
  has_many :deliberation_assignments, :foreign_key => :applicant, dependent: :destroy
  before_save :default_preferences
  after_save :default_rankings
  validates_format_of :email, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :on => :save
  validates_uniqueness_of :name, :scope => [:deliberation_id]

  def default_rankings
  	committee1 = Committee.find(self.preference1)
	committee2 = Committee.find(self.preference2)
	committee3 = Committee.find(self.preference3)
	committees = [committee1, committee2, committee3]
	for c in committees
		# if c.name != "Executives" and c.name != "General Members"
		if self.deliberation_id and ApplicantRanking.where(deliberation_id: self.deliberation_id).where(applicant: self).where(committee: c).length == 0
			rank = ApplicantRanking.new
			rank.committee = c.id
			rank.applicant = self
			rank.deliberation_id = self.deliberation_id
			rank.value = 50
			rank.save
			self.applicant_rankings << rank
		end
	end
  end

  def default_preferences
  	gm_id = 1
  	if Committee.where(id: self.preference1).length == 0
  		self.preference1 = gm_id
  	end
  	if Committee.where(id: self.preference2).length == 0
  		self.preference2 = gm_id
  	end
  	if Committee.where(id: self.preference3).length == 0
  		self.preference3 = gm_id
  	end
  end
end

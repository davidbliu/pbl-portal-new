class ApplicantRanking < ActiveRecord::Base
  attr_accessible :applicant, :committee, :notes, :value, :deliberation_id
  belongs_to :applicant, :foreign_key => 'applicant'
  belongs_to :committee, :foreign_key => 'committee'
  belongs_to :deliberation, :foreign_key => 'deliberation_id'
  # validates_uniqueness_of :applicant, :scope => [ :deliberation_id]
  # def get_applicant
  # 	return Applicant.find(self.applicant)
  # end

 end

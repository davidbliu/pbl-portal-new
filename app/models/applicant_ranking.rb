class ApplicantRanking < ActiveRecord::Base
  attr_accessible :applicant, :committee, :notes, :value, :deliberation_id
  belongs_to :applicant, :foreign_key => 'applicant'
  # validates_uniqueness_of :applicant, :scope => [:committee, :deliberation_id]
  def get_applicant
  	return Applicant.find(self.applicant)
  end

 end

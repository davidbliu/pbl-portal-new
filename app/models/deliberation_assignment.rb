class DeliberationAssignment < ActiveRecord::Base
  attr_accessible :applicant, :committee, :deliberation_id
  belongs_to :applicant, :foreign_key => :applicant
  belongs_to :deliberation
end

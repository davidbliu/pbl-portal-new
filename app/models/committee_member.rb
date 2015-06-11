# == Schema Information
#
# Table name: committee_members
#
#  id                       :integer          not null, primary key
#  member_id                :integer
#  committee_id             :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  committee_member_type_id :integer
#

# == Description
#
# A relationship between Committee and Member.
#
# Has a type that acts as a classification/tiering between each committee member.
#
# == Associations
#
# === Belongs to:
# - Member
# - Committee
# - CommitteeMemberType
# - TODO: Semester
class CommitteeMember < ActiveRecord::Base
  # attr_accessible :committee_id, :committee_member_type_id, :member_id, :semester_id

  belongs_to :committee_member_type
  belongs_to :member
  belongs_to :committee
  belongs_to :semester, foreign_key: :semester_id
  # current_semester_id = Semester.current_semester.id
  # default_scope where(semester_id: current_semester_id)

  # member cannot belong to muliple committees in the same semester
  validates :member_id, :uniqueness => {:scope => [:committee_id, :semester_id]}
end

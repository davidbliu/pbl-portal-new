# == Schema Information
#
# Table name: committee_member_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  tier       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# == Description
#
# A type of CommitteeMember.
#
# == Fields
# - name: the name of the type
# - tier: the tier of the type
#
# == Associations
#
# === Has many:
# - CommitteeMember
# - Committee
# - Member
class CommitteeMemberType < ActiveRecord::Base
  # attr_accessible :name, :tier

  has_many :committee_members
  has_many :committees, through: :committee_members
  has_many :members, through: :committee_members

  # Get or create the CM committee member type
  def self.cm
    CommitteeMemberType.where(
      name: "cm",
      tier: 1,
    ).first_or_create!
  end

  # Get or create the chair committee member type
  def self.chair
    CommitteeMemberType.where(
      name: "chair",
      tier: 2,
    ).first_or_create!
  end

  # Get or create the GM committee member type
  def self.gm
    CommitteeMemberType.where(
      name: "gm",
      tier: 0,
    ).first_or_create!
  end

  # Get the Executive position with the given name
  def self.exec(position)
    exec_type = CommitteeMemberType.where(
      "lower(name) = :position and tier = 3",
      position: position.downcase
    ).first
  end

  # Create a new Executive position with the given name, if it does not already exist
  # NOTE: the reason this and the getter for execs are separate, unlike those for the other
  # positions, is because these methods taken in a parameter that could potentially contain a typo,
  # and if used as a mixed getter/setter, could create unnecessary entries in the database.
  def self.new_exec(position)
    CommitteeMemberType.where(
      name: position.downcase,
      tier: 3
    ).first_or_create!
  end

end

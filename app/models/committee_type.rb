# == Schema Information
#
# Table name: committee_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  tier       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# == Description
#
# A type of Committee.
#
# == Fields
# - name: the name of the type
# - tier: the tier of the type
#
# == Associations
#
# === Has many:
# - Committee
class CommitteeType < ActiveRecord::Base
  # attr_accessible :name, :tier

  has_many :committees

  # Get or create the default committee type
  def self.committee
    CommitteeType.where(
      name: "committee",
      tier: 1,
    ).first_or_create!
  end

  # Get or create the admin committee type
  def self.admin
    CommitteeType.where(
      name: "admin",
      tier: 2,
    ).first_or_create!
  end

  # Get or create the general members committee type
  def self.general
    CommitteeType.where(
      name: "general",
      tier: 0,
    ).first_or_create!
  end

end

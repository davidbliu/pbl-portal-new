# == Schema Information
#
# Table name: committees
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  abbr              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  committee_type_id :integer
#

# == Description
#
# A committee, consisting of a group of Members.
#
# Has a type that acts as a classification/tiering between committees.
#
# == Fields
# - name: name of the committee
# - abbr: the committee's abbreviation
#
# == Associations
#
# === Belongs to:
# - CommitteeType
#
# === Has many:
# - CommitteeMember
# - Member
class Committee < ActiveRecord::Base
  attr_accessible :name, :committee_type_id, :abbr

  belongs_to :committee_type

  has_many :committee_members, dependent: :destroy
  has_many :members, through: :committee_members

  """ 
  convenience methods for getting specific committees
  """
  def self.gm
    return Committee.where(name: "General Members").first
  end

  def self.ht
    return Committee.where(name: "Historians").first
  end

  def self.pb
    return Committee.where(name: "Publications").first
  end

  def self.wd
    return Committee.where(name: "Web Development").first
  end

  def self.committee_hash
    chash = Rails.cache.read("committee_hash")
    if chash != nil
      return chash
    end
    chash = Committee.all.index_by(&:id)
    Rails.cache.write('committee_hash', chash)
    return chash
  end

  # Show the committee's rating.
  def rating(semester = Semester.current_semester)
    if self.cms(semester).count > 0
      sum = 0.0

      self.cms(semester).each do |committee_member|
        sum += committee_member.member.total_points(semester)
      end

      rating = (sum / self.cms(semester).count).round(2)
    else
      rating = 0.0
    end
    return rating
  end

  # Only the chairs and CMs of the committee
  def cms(semester = Semester.current_semester)
    if self.committee_type == CommitteeType.general
      self.committee_members.where(committee_member_type_id: CommitteeMemberType.where(
        "lower(name) = 'general member' or lower(name) = 'gm'"
      )).where(semester_id: semester.id)
    else
      if self.name == "Executive"
        self.committee_members.where(semester_id: semester.id)
      else
        self.committee_members.where(committee_member_type_id: CommitteeMemberType.where(
          "lower(name) = 'cm' or lower(name) = 'chair'"
        )).where(semester_id: semester.id)
      end
    end
  end
end

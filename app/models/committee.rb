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


  # relationship between members and committees through join table
  has_and_belongs_to_many :members, join_table: 'committee_members'
  
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

  def self.ex 
    return Committee.where(name: "Executives").first
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
   return nil
  end
end

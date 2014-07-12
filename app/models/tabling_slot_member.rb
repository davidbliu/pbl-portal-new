# == Schema Information
#
# Table name: tabling_slot_members
#
#  id              :integer          not null, primary key
#  member_id       :integer
#  tabling_slot_id :integer
#  status_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# == Description
# A relationship between a Member and a TablingSlot.
# Has a status that describes the relationship.
#
# == Associations
#
# === Belongs to:
# - Member
# - TablingSlot
# - Status
class TablingSlotMember < ActiveRecord::Base

  belongs_to :member
  belongs_to :tabling_slot
  belongs_to :status

  # Set itself's status to the Status with the given name.
  # Returns false if the status was not found
  #
  # === Parameters
  # - status: the name of the status
  def set_status_to(status)
    status = Status.where(name: status).first
    if status
      self.status = status
      self.save
    else
      false
    end
  end
end

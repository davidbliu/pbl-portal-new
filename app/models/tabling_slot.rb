# == Schema Information
#
# Table name: tabling_slots
#
#  id         :integer          not null, primary key
#  start_time :datetime
#  end_time   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# == Description
# A segment of time during which members table.
#
# == Fields
# - start_time: the starting time of the slot
# - end_time: the ending time of the slot
#
# == Associations
#
# === Has many:
# - TablingSlotMember
# - Member
class TablingSlot < ActiveRecord::Base
  POINTS = 1

  # attr_accessible :end_time, :start_time

  has_many :tabling_slot_members, dependent: :destroy
  has_many :members, through: :tabling_slot_members

  def member_names
  	return self.members.pluck(:name)
  end

  def member_name_id_map

  	return self.tabling_slot_members.map{|m| {"name"=>m.member.name, "id"=>m.id, "tsm_id"=>m.id}}
  end
end
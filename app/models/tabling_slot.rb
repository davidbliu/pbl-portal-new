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
  # POINTS = 1

  attr_accessible :member_ids
  serialize :member_ids

  def day
    return self.time / 24
  end

  def hour 
    return self.time % 24
  end

  def day_string
    day_strings = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    return day_strings[self.day]
  end

  def day_string_abbrev
    day_string_abbrevs = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun']
    return day_string_abbrevs[self.day]
  end

  def time_string
    return self.day_string + ' at ' + self.hour_string
  end

  def hour_string
    h = self.hour % 12
    if h==0
      h=12
    end
    return h.to_s+':00'
  end
  # , :start_time

  # has_many :tabling_slot_members, dependent: :destroy
  # has_many :members, through: :tabling_slot_members

  # def member_names
  # 	return self.members.pluck(:name)
  # end

  # def member_name_id_map

  # 	return self.tabling_slot_members.map{|m| {"member_id"=>m.member.id, "name"=>m.member.name, "id"=>m.id, "tsm_id"=>m.id,"profile"=>m.member.profile_url, "position"=>m.member.position, "exec"=>m.member.exec?}}
  # end
end

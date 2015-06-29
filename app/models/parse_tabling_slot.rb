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
class ParseTablingSlot < ParseRecord::Base
  fields :member_ids, :time

  # needs a time
  validates :time, presence: true

  def day
    return self.time / 24
  end

  def hour 
    return self.time % 24
  end

  def members
    """ returns an array of members that are in this slot """ 
    member_hash = ParseMember.current_members_hash
    member_ids.map{|id| member_hash[id]}
  end

  def time_string
    return self.day_string + ' at ' + self.hour_string
  end

  """ below this are helper methods that are hidden """

  def day_string
    day_strings = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    return day_strings[self.day]
  end

  def day_string_abbrev
    day_string_abbrevs = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun']
    return day_string_abbrevs[self.day]
  end

  def hour_string
    h = self.hour % 12
    if h==0
      h=12
    end
    return h.to_s+':00'
  end

  def migrate
    TablingSlot.all.each do |ts|
    end
  end

end

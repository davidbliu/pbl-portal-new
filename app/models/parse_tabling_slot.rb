class ParseTablingSlot < ParseResource::Base
  fields :member_ids, :time

  # needs a time
  validates :time, presence: true

  def day
    return self.time / 24
  end

  def hour 
    return self.time % 24
  end

  """ get all tabling slots """
  def get_all
    slots = Rails.cache.read('tabling_slots')
    if slots != nil
      return slots
    end
    slots = ParseTablingSlot.all
    Rails.cache.write('tabling_slots', slots)
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

""" migration methods """
  def self.migrate
    old_member_hash = ParseMember.old_hash
    puts 'recieved old hash'
    ParseTablingSlot.destroy_all
    puts 'destroyed all slots'
    parse_slots = Array.new
    TablingSlot.all.each do |ts|
      ps = ParseTablingSlot.new
      member_ids = Array.new
      valid_ids = Array.new
      ts.member_ids.each do |mid|
        if old_member_hash.keys.include?(mid)
          valid_ids << mid
        end
      end
      ps.member_ids = valid_ids.map{|x| old_member_hash[x].id}
      ps.time = ts.time
      parse_slots << ps
    end
    ParseTablingSlot.save_all(parse_slots)
  end

end

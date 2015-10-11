class ParseTablingSlot < ParseResource::Base
  fields :time, :member_emails, :day, :hour

  def get_member_emails
    if self.member_emails and self.member_emails != '' 
      return self.member_emails.split(',')
    end
    return Array.new
  end

  def to_json
  	return {'time'=> self.time, 'member_emails'=>self.member_emails.split(',')}
  end


  def assign_member(email)
    emails = self.get_member_emails
    emails << email 
    self.member_emails = emails.join(',')
  end

  def self.init
    ParseTablingSlot.destroy_all(ParseTablingSlot.all.to_a)
    slots = []
    slots << (10..10+4).to_a
    slots << (34..34+4).to_a
    slots << (58..58+4).to_a
    slots << (82..82+4).to_a
    slots << (106..106+4).to_a
    times = slots.flatten()
    tablingSlots = []
    for time in times
      tablingSlots << ParseTablingSlot.new(time: time, day: TablingManager.get_day(time), hour: TablingManager.get_hour(time))
    end
    ParseTablingSlot.save_all(tablingSlots)
  end

end

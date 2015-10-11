class TablingSlot < ParseResource::Base
  fields :time, :member_emails, :day, :hour, :type

  def get_member_emails
    if self.member_emails and self.member_emails != '' 
      return self.member_emails.split(',')
    end
    return Array.new
  end

  def assign_member(email)
    emails = self.get_member_emails
    emails << email 
    self.member_emails = emails.join(',')
  end


  def self.init
    TablingSlot.destroy_all(TablingSlot.all.to_a)
    slots = []
    slots << (10..10+4).to_a
    slots << (34..34+4).to_a
    slots << (58..58+4).to_a
    slots << (82..82+4).to_a
    slots << (106..106+4).to_a
    times = slots.flatten()
    tablingSlots = []
    for time in times
      tablingSlots << TablingSlot.new(time: time, type: 'weekly')
    end
    TablingSlot.save_all(tablingSlots)
  end

  def to_json
    js = {}
    js['chairs'] = self.chairs
    js['member_emails'] = self.get_member_emails
    js['time'] = self.time
    return js
  end

  def chairs
    member_hash = SecondaryEmail.email_lookup_hash
    return self.get_member_emails.select{|x| member_hash.keys().include?(x) ? member_hash[x].officer? : false}
  end

  def self.tabling_slots
  end

end

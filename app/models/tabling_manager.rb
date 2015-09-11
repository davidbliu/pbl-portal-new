require 'set'

class TablingManager < ActiveRecord::Base

""" displaying tabling schedules """

def self.time_string(time)
  return self.get_day(time) + ' at '+self.get_hour(time)
end


def self.current_slots
  tabling_time = TablingManager.tabling_hash[email].time
  tabling_string = TablingManager.time_string[tabling_time]
end

def self.times_hash
    times = []
    times << (8..8+15).to_a
    times << (32..32+15).to_a
    times << (56..56+15).to_a
    times << (80..80+15).to_a
    times << (104..104+15).to_a
    times = times.flatten()

    times_hash = {}
    times.each do |time|
      day = self.get_day(time)
      if not times_hash.keys.include?(day)
        times_hash[day] = []
      end
      times_hash[day] << time
    end
    return times_hash
end

def self.get_day(time)
  day = time / 24
  day_strings = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  day_string = day_strings[day]
  return day_string
end

def self.get_hour(time)
  hour = time % 24
  h = hour % 12
  if h==0
    h=12
  end
  half = hour >= 12 ? 'pm': 'am'
  hour_string =  h.to_s+':00'+half
  return hour_string
end

# hash from member email to tabling slot
def self.tabling_hash
  a = Rails.cache.read('tabling_hash')
  if a
    return a
  end
  schedule = self.tabling_schedule
  th = Hash.new
  if schedule
    schedule.keys.each do |day|
      schedule[day].each do |slot|
        slot.member_emails.split(',').each do |email|
          th[email] = slot
        end
      end
    end
    return th
  end
  return nil

end

def self.tabling_schedule
  """ returns the tabling schedule in a Hash
  key is tabling day (0 to 6)
  value is Array of TablingSlot objects sorted by time
  """
  schedule = Rails.cache.read('tabling_schedule')
  if schedule != nil
    return schedule
  end
  puts 'calculating tabling schedule'
  slots = ParseTablingSlot.all.sort_by{|x| x.time}
  if slots.length == 0
    Rails.cache.write('tabling_schedule', nil)
    return nil
  end
  tabling_hash = {}
  slots.each do |slot|
    if not tabling_hash.keys.include?(slot.day)
      tabling_hash[slot.day] = []
    end
    tabling_hash[slot.day] << slot
  end
  Rails.cache.write('tabling_schedule', tabling_hash)
  return tabling_hash
end


"""switching tabling"""




""" use tabling histogram to generate tabling"""
def self.generate_tabling
  slots = {}
  assignments = {}
  assigned = Set.new
  member_slots = {}
  TablingHist.all.each do |hist|
    slots[hist.time] = hist.get_confirmed + hist.get_unconfirmed
    assignments[hist.time] = []
  end
  # make member_slots
  slots.keys.each do |slot|
    slots[slot].each do |member|
      if not member_slots.keys.include?(member)
        member_slots[member] = []
      end
      member_slots[member] << slot
    end
  end
  puts 'this is member_slots'
  puts member_slots

  slots_available = Set.new(member_slots.values.flatten())

  
  while member_slots.keys.length > 0
    slots_available = Set.new(member_slots.values.flatten())
    slot = self.get_least_filled_slot(slots_available, assignments)
    member = slots[slot].select{|x| not assigned.include?(x)}.sample
    assigned.add(member)
    assignments[slot] << member
    member_slots = member_slots.except(member)
    puts 'assigned '+member+' into slot '+slot.to_s+' which has '+assignments[slot].length.to_s
  end
  puts assignments

  ParseTablingSlot.destroy_all
  tabling_slots = []
  assignments.keys.each do |time|
    tabling_slots << ParseTablingSlot.new(time: time, member_emails:assignments[time].join(','),
      day: TablingManager.get_day(time), hour: TablingManager.get_hour(time))
  end
  ParseTablingSlot.save_all(tabling_slots)

end

def self.get_least_filled_slot(slots, assignments)
  mcv = [slots]
  num_assigned = 10000
  slots.each do |slot|
    if assignments[slot].length < num_assigned
      num_assigned = assignments[slot].length
      mcv = [slot]
    elsif assignments[slot].length == num_assigned
      mcv << slot
    end
  end
  return mcv.sample

end

def self.get_most_constrained_slot(slots, assignments, assigned)
  mcv = slots
  num_assigned = 10000
  slots = slots.keys.select{|x| self.can_assign(slots[x], assigned).length > 0}
  slots.each do |slot|
    if assignments[slot].length < num_assigned
      num_assigned = assignments[slot].length
      mcv = [slot]
    elsif assignments[slot].length == num_assigned
      mcv << slot
    end
  end
  return mcv.sample
end

def self.can_assign(slot_members, assigned)
  return slot_members.select{|x| not assigned.include?(x)}
end


def self.get_initial_assignments(histogram)
  assignments = {}
  histogram.each do |hist|
    assignments[hist.time] = []
  end
  return assignments
end

"""generating tabling"""

def self.generate_tabling_slots(assignments)
	""" deletes all current tabling slots and regenerates tabling schedule
	"""
  Rails.cache.write('tabling_schedule', nil)
  ParseTablingSlot.destroy_all
  slots = Array.new
  assignments.keys.each do |time|
    ts = ParseTablingSlot.new
    ts.time = time
    ts.member_ids = assignments[time].map {|x| x.id}
    p ts.time
    p ts.member_ids
    # ts.save
    slots << ts
  end
  ParseTablingSlot.save_all(slots)
end

  def self.generate_tabling_assignments(times, members)
    """
    create assignment hash of timeslot (hour) to member list
    times is an Array of times that you want tabling to happen (like [5,7,4,34])
    members is a Array of member ids
    """
    unassigned = Set.new(members)
    assignments = Hash.new
    while unassigned.length() > 0
      mcv = get_MCV(unassigned, times)
      lcv = get_LCV(assignments, mcv, times)
      if not assignments.has_key?(lcv)
        assignments[lcv] = Array.new
      end
      assignments[lcv] << mcv
      unassigned.delete(mcv)
    end

    return assignments
  end

  def self.get_MCV(unassigned, times)
  	""" the MCV is the most constrained value, or the member with the least
  	available slots for this week
  	"""
    mcv = []
    max_clashes = -1
    unassigned.each do |member|
      commitments = member.commitments
      clashes = 0
      for time in times
        if commitments[time] == 1
          clashes += 1
        end
      end
      if clashes > max_clashes
        max_clashes = clashes
        mcv = [member]
      elsif clashes == max_clashes
        mcv << member
      end
    end

    mcv = mcv.sample
    return mcv
  end


  def self.get_LCV(assignments, member, times)
  	""" the LCV is the least constrained value, or the slot that 
  	has the least members so far
  	"""
    lcv = []
    min_capacity = 1000000
    times.each do |time|
      capacity = 0
      if assignments.has_key?(time)
        capacity = assignments[time].length
      end
      if capacity < min_capacity
        min_capacity = capacity
        lcv = [time]
      elsif capacity == min_capacity
        lcv << time
      end
    end

    lcv = lcv.sample
    return lcv
  end
end

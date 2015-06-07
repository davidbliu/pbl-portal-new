class TablingManager < ActiveRecord::Base


""" displaying tabling schedules """


def self.tabling_schedule
	""" returns the tabling schedule in a nice, easy to work with format
	for the front end to display. 
	schema returned is key = timeid (0 to 167) and value = list of (member_id, member_name)
	"""
	ts = Rails.cache.read('tabling_schedule')
	if ts != nil
		return ts
	end

	ts = Hash.new
	TablingSlot.all.each do |tabling_slot|
		member_ids = tabling_slot.member_ids
		members = Member.where('id in (?)', member_ids).pluck(:id, :name)
		ts[tabling_slot.time] = members
	end
	Rails.cache.write('tabling_schedule', ts)
	return ts
end

"""switching tabling"""


"""generating tabling"""

def self.generate_tabling_slots(assignments)
	""" deletes all current tabling slots and regenerates tabling schedule
	"""
  TablingSlot.destroy_all
  assignments.keys.each do |time|
    ts = TablingSlot.new
    ts.time = time
    ts.member_ids = assignments[time].map {|x| x.id}
    p ts.time
    p ts.member_ids
    ts.save
  end
  p 'there are now ' + TablingSlot.all.length.to_s + ' slots'
end

  def self.generate_tabling_assignments(times, members)
    """
    create assignment hash of timeslot (hour) to member list
    times is an array of times that you want tabling to happen (like [5,7,4,34])
    members is a list of member ids
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

    p 'there were '+mcv.length.to_s + ' mcvs'
    mcv = mcv.sample
    p 'mcv was '+mcv.name + ' with '+max_clashes.to_s
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

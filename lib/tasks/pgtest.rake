



task :points_test => :environment do
	p 'hi'
	# em = EventMember.first
	# EventMember.find_each do |em|
	# 	p em.semester
	# Member.all.each do |mem|
	# 	p mem.name
	# 	begin
	# 		p mem.cms.pluck(:name)
	# 	rescue
	# 		p 'failed'
	# 	end
	# 	# p mem.total_points('all')
	# 	# p mem.tabling_slots
	# end
	# p Member.currently_in_committee(Committee.where(name: 'Historian').first).pluck(:name)

	# events = Event.all
	# events.each do |event|
	# 	'aaaa'
	# 	p event.attendance_rate(Committee.where(name: "Historian").first)
	# end
	p 'bye'
	p 'this semester is'
	p Semester.current_semester

end

task :rankings => :environment do
	current_member = Member.where(name: "David Liu").first
	# semester_events
	attended_event_members = EventMember.where("event_id IN (?)", Event.this_semester.pluck(:id).collect{|i| i.to_s})
	attended_event_ids = attended_event_members.where(member_id: current_member.id).pluck(:event_id)
	@attended_events = Event.where("id in (?)", attended_event_ids.collect{|i| i.to_s})

	@attended_events.all.each do |event| 
		p event.name + ": " + event.points.to_s + " points"
	end

	p 'calculating cm points'
	cm_points_list = current_member.cms.map{|cm| {'name' => cm.name, 'points' => cm.total_points}}
	@cm_points_list = cm_points_list.sort_by{|obj| obj['points']}.reverse
	p @cm_points_list

	p 'calculating all member points'
	points_list = Member.all.map{|m| {'name' => m.name, 'points' => m.total_points}}
	@points_list = points_list.sort_by{|obj| obj['points']}.reverse
	p @points_list
end

task :mark => :environment do
	# p Member.current_gm_ids
	@semester_events = Event.this_semester
		@current_cms = Member.current_members
		# event_member_join = Event.join(curr)
		event_members = EventMember.all
		# @attended_dict = 
		@current_cms.each do |cm|

			# @semester_events.each do |event|
			# 	if event_members.where(event_id: event.id.to_s).where(member_id: cm.id).length > 0
			# 		p 'yes'
			# 	else
			# 		p 'no'
			# 	end
			# end

			#
			# generate record of cm events
			#
			
			begin
				mapping = cm.attendance_mapping(@semester_events)
				p cm.name
				p mapping
				# p attended
			rescue
				name = cm.name
				p 'failed here'
				# p cm.name
				# current_member = Member.where(name: name).first
				# mems = EventMember.where(member_id: current_member.id)
				# for m in mems
				# 	if m.event_id.length > 5 or m.event_id == ""
				# 		p m.event_id
				# 		m.destroy
				# 	end
				# end

			end
		end
end

task :clean => :environment do
	current_member = Member.where(name: "Sammy Tong").first
	mems = EventMember.where(member_id: current_member.id)
	for m in mems
		p m.event_id
	end

	# p event_ids
end

task :tabling => :environment do
	# for m in Member.all
	# 	p m.name
	# 	p m.tabling_slots
	# end
	require 'chronic'
	# p tabling_start
	start_day = Chronic.parse('0 april 14', :context => :past)
	end_day = start_day+5.days
	week = (start_day..end_day)
	p start_day.class
	p end_day
	p week.class

	#
	# testing old controller
	#
    @tabling_slots = TablingSlot.where(
      "start_time >= :tabling_start and start_time <= :tabling_end",
      tabling_start: start_day,
      tabling_end: end_day,
    ).order(:start_time)

    if !@tabling_slots.empty?
      @earliest_time = @tabling_slots.first.start_time

      @tabling_days = Hash.new
      @tabling_slots.each do |tabling_slot|
        @tabling_days[tabling_slot.start_time.to_date] ||= Array.new
        tabling_day = @tabling_days[tabling_slot.start_time.to_date]

        tabling_day << tabling_slot
      end
    end

    p 'done'
    p @tabling_slots
    p @tabling_slots.length
end
task :chairs => :environment do 
	# Member.all.each do |m|
		# p m.position
	# end

	# chair_exec_tier = CommitteeMemberType.where("tier > 1").pluck(:id)
	# chair_ids = CommitteeMember.where(semester: Semester.current_semester).where('committee_member_type_id IN (?)', chair_exec_tier).pluck(:member_id)
	# chair_exec_list = Member.where('id IN (?)', chair_ids)
	# p (Member.current_chairs.pluck(:name)+Member.current_chairs.pluck(:name))
	p Member.current_members.pluck(:name)
	# chair_exec_tier.all.each do |type|
	# 	p type.name + ' '+ type.tier.to_s
	# end
	

end
task :commitment => :environment do
	current_member = Member.where(name: "Sammy Tong").first
	p current_member.commitments

end
task :generate => :environment do
	hrs = ['9','10','11','12','13']
	timeslots = Hash.new
	timeslots[0] = hrs
	timeslots[1] = hrs
	timeslots[2] = hrs
	timeslots[3] = hrs
	timeslots[4] = hrs
	timeslots[5] = hrs
	timeslots[6] = hrs

	p 'clearing slots'
	clear_this_week_slots
	p 'starting to generate'
	@slots = Array.new
    timeslots.keys.each do |key|
      day = Date::DAYNAMES[key.to_i]
      if timeslots[key].length > 0
        timeslots[key].each do |h|
          hour = h.to_i
          @slots << TablingSlot.where(
            start_time: Chronic.parse("#{hour} this #{day}"),
            end_time: Chronic.parse("#{hour + 1} this #{day}")
          ).first_or_create!
        end
      end
    end
    # p @slots
    @mems = Member.current_members
    generate_tabling_schedule(@slots, @mems)
    p 'done'
end

def tabling_start
    if DateTime.now.cwday > 5 # If past Friday
      Chronic.parse("0 this monday")
    elsif DateTime.now.cwday == 1 # If Monday
      Chronic.parse("0 today")
    else
      Chronic.parse("0 last monday")
    end
end

def clear_this_week_slots
	days = (0..7).to_a
	hours = (1..24).to_a
	days.each do |key|
	  day = Date::DAYNAMES[key]
	  hours.each do |hour|
	    TablingSlot.where(
	      start_time: Chronic.parse("#{hour} this #{day}"),
	      end_time: Chronic.parse("#{hour + 1} this #{day}")
	    ).destroy_all
	  end
	end
end

#
# generate tabling logic
#

# input slots: tabling slots that you want to fill
# return assignments hash key: slot, value: array of members}
  def generate_tabling_schedule(slots, members)
    puts "generating schedule"
    convert_commitments(members)
    puts "commitments converted"
    #initialize your assignment hash
    assignments = Hash.new
    assignments["manual"] = Array.new
    manual_assignments = Array.new
    for s in slots
      assignments[s] = Array.new
    end
    curr_member = get_MCV(assignments, members)
    while curr_member != nil do
      puts "assigning"
      puts curr_member
      slot = get_LCV(assignments, curr_member)
      if slot != nil
        # assign student to the slot
        assignments[slot] << curr_member
      else
        # you cant assign this member
        manual_assignments << curr_member
        assignments["manual"] << curr_member
      end
      curr_member = get_MCV(assignments, members)
    end
    save_tabling_results(assignments, slots)
    return assignments
  end

  # return the hardest to work with member (least slots open)
  def get_MCV(assignments, members)
    difficult_members = Array.new
    num_slots = 1000
    for member in members
      if not is_assigned(assignments, member)
        available_slots = get_current_available_slots(assignments, member).length
        if available_slots < num_slots
          difficult_members = Array.new
          difficult_members << member
          num_slots = available_slots
        elsif available_slots == num_slots
          difficult_members << member
        end
      end
    end
    # should be random?
    # TODO: backtracking
    return difficult_members.sample
  end

  # least constrained value
  # slot with highest capacity after member has been assigned
  def get_LCV(assignments, member)
    max_capacity = -1;
    lcv_slots = Array.new
    slots = get_current_available_slots(assignments,member)
    for slot in slots
      remaining_capacity = 5000-assignments[slot].length
      if remaining_capacity > max_capacity
        lcv_slots = Array.new
        max_capacity = remaining_capacity
        lcv_slots << slot
      elsif remaining_capacity == max_capacity
        lcv_slots << slot
      end
    end
    return lcv_slots.sample
  end

  # returns if start1, end1, conflicts with start2, end2
  def conflicts(s1,e1,s2,e2)
    if s1<=s2 and e1>s2
      return true
    elsif s1<e2 and s1>s2
      return true
    end
    return false
  end

  # return if member has been assigned
  def is_assigned(assignments, member)
      for key in assignments.keys
        list = assignments[key]
        if list.include? member
          return true
        end
      end
      return false
    end

  def convert_commitments(members)
  	# all_commitments = Commitment.all
    members.each do |member|
      # all_commitments.where(member_id: member.id).each do |c|
      member.commitments.each do |c|
        if c.day
          d = c.day
          s = c.start_hour
          e = c.end_hour
          day = Date::DAYNAMES[d]
          start = Chronic.parse("#{s} this #{day}")
          endt =  Chronic.parse("#{e} this #{day}")
          c.start_time = start
          c.end_time = endt
          c.save
        else
          c.destroy
        end
      end
    end
  end
   # assumes each slot has same capacity 5
  # TODO add capacity to tabling_slots table
  def get_current_available_slots(assignments, member)
    slots = Array.new
    # puts "getting slots for "+member.name
    assignments.keys.each do |key|
      slot = key
      conflicts = true
      if not slot == "manual"
        conflicts = false
        for c in member.commitments
          d = c.day
          s = c.start_hour
          e = c.end_hour
          # TODO have these calculated somewhere else
          if d
            # puts "taking a while on this part"
            day = Date::DAYNAMES[d]
            # start = Chronic.parse("#{s} this #{day}")
            # endt =  Chronic.parse("#{e} this #{day}")
            start = c.start_time
            endt = c.end_time
            if day and conflicts(start, endt, slot.start_time, slot.end_time)
              conflicts = true
              break
            end
          end
        end
      end
      if not conflicts
        if assignments[slot].length < 5000 # hard coded capacity
          slots << slot
        end
      end
    end
    return slots
  end

def save_tabling_results(assignments, slots)
  for tabling_slot in slots
      if tabling_slot
        for member in assignments[tabling_slot]
          slot_member = TablingSlotMember.where(member_id: member.id).where(tabling_slot_id: tabling_slot.id).first
          if slot_member
            puts "THe member is already there"
          else
            slot_member = TablingSlotMember.new
            slot_member.member_id = member.id
            slot_member.tabling_slot_id = tabling_slot.id
            slot_member.save
          end
          if not tabling_slot.members.include? member
            tabling_slot.members << member
          end
        end
      else
        puts "Tabling slot not found"
      end
    end
    # handle the manually assign members
    odd_slot = TablingSlot.new
    # odd_slot.start_time = Date.now
    # odd_slot.end_time = 1
    day = Date::DAYNAMES[6]
    hour = 1
    odd_slot = TablingSlot.where(
          start_time: Chronic.parse("#{hour} this #{day}"),
          end_time: Chronic.parse("#{hour + 1} this #{day}")
        ).first_or_create!
    odd_slot.save
    for member in assignments["manual"]
      slot_member = TablingSlotMember.new
      slot_member.member_id = member.id
      slot_member.tabling_slot_id = odd_slot.id
      slot_member.save
      if not odd_slot.members.include? member
        odd_slot.members << member
      end
    end
   end

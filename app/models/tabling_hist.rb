require 'timeout'
require 'set'
class TablingHist < ParseResource::Base
	fields :slot_id, :unconfirmed, :time, :confirmed, :num_members, :num_confirmed, :num_unconfirmed

	def get_confirmed
		self.confirmed and self.confirmed != '' ? self.confirmed.split(',') : []
	end
	def get_unconfirmed
		self.unconfirmed and self.unconfirmed != '' ? self.unconfirmed.split(',') : []
	end

	def update_counts
		self.num_confirmed = self.get_confirmed.length
		self.num_unconfirmed = self.get_unconfirmed.length
	end
	
	def day
		return self.time / 24
	end

	def hour 
		return self.time % 24
	end

	def hour_string
		h = self.hour % 12
		if h==0
		  h=12
		end

		half = self.hour >= 12 ? 'pm': 'am'
		return h.to_s+':00 '+half
	end
	def members
		member_hash = Member.member_hash
		member_ids.map{|id| member_hash[id]}
	end

	

	def self.push_item(array_string, item)
		newArray = array_string.split(',')
		newArray << item
		return Set.new(newArray).to_a.join(',')
	end

	def self.remove_item(array_string, item)
		newArray = array_string.split(',')
		newArray.delete(item)
		return newArray.join(',')
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

	def self.available_slots
	end

	def self.initialize_histogram(members, slots)
		num = 3
		max_capacity = (members.length * num)/slots.length + 1

		puts 'initializing histogram'

		members = members.map{|x| x.email}
		assignments = self.get_empty_assignments(slots)

		commitments = self.get_commitments_hash(members)
		puts 'received commitments_hash'

		slot_counts = {}
		slots.each do |slot|
			slot_counts[slot] = 0
		end

		member_counts = {}
		members.each do |email|
			member_counts[email] = 0
		end
		
		unfinished = members.select{|x| member_counts[x] < num}
		puts 'placing members into histogram'

		while unfinished.length > 0
				remaining_slots = slots.select{|x| slot_counts[x] < max_capacity}
				mcv = self.get_most_constrained_member(remaining_slots, unfinished, assignments, commitments)

				puts "\t" + 'mcv: '+mcv
				lcv = self.get_least_constrained_slot(remaining_slots, mcv, assignments, commitments[mcv])
				puts "\t"+'lcv: '+lcv.to_s
				assignments[lcv] << mcv
				puts "\t"+'added '+mcv+' to '+lcv.to_s

				slot_counts[lcv] += 1
				member_counts[mcv] +=1 
				unfinished = members.select{|x| member_counts[x] < num}
		end

		puts assignments
		hist = []
		assignments.keys.each do |slot|
			h = TablingHist.new(time: slot, unconfirmed: assignments[slot].join(','), num_members: assignments[slot].length, confirmed: '')
			h.update_counts
			hist << h
		end

		TablingHist.destroy_all
		puts 'destroyed previous histogram'

		TablingHist.save_all(hist)
	end

	#note: commitments are slots that the member CAN make
	def self.get_commitments_hash(members)
		c = Commitments.limit(10000).all
		commitments = {}
		members.each do |email|
			cs = c.select{|x| x.member_email == email}
			if cs.length > 0
				commitments[email] = cs[0].commitments.map{|x| x.to_i}
			else
				commitments[email] = (0..167).to_a
			end
		end
		return commitments
	end


	# get slot with the fewest members currently
	def self.get_least_constrained_slot(slots, member, assignments, commitments)
		lcv = slots
		slots = slots_can_make(slots, member, assignments, commitments)
		# puts 'here are the slots '
		# puts slots.to_s
		num_in_slot = 100000
		slots.each do |slot|
			if assignments[slot].length < num_in_slot
				lcv = [slot]
				num_in_slot = assignments[slot].length
			elsif assignments[slot].length == num_in_slot
				lcv << slot
			end
		end
		# if num_in_slot == 10000

		# 	puts 'could not find a good slot for you'
		# end
		return lcv.sample
	end

	# get the member with the fewest slots he can make
	def self.get_most_constrained_member(slots, members, assignments, commitments_hash)
		mcv = []
		can_make = 1000000
		members.each do |member|
			can_make_slots = self.slots_can_make(slots, member, assignments, commitments_hash[member])
			if can_make_slots.length < can_make
				mcv = [member]
				can_make = can_make_slots.length
			elsif can_make_slots.length == can_make
				mcv << member
			end
		end
		return mcv.sample
	end

	def self.slots_can_make(slots, member, assignments, commitments)
		return slots.select{|x| commitments.include?(x) and not assignments[x].include?(member)}
	end

	def self.get_empty_assignments(slots)
		h = Hash.new
		slots.each do |slot|
			h[slot] = []
		end
		return h
	end


end
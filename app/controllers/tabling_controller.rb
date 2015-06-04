# require 'chronic'
require 'set'
class TablingController < ApplicationController



  def manage
    @all_slots = TablingSlot.all
  end


	def index
  end
	
	#
	# options for secretary to generate new tabling schedule
	#
	def options
		cms = Member.current_cms
    officers = Member.current_chairs
    
	end

	#
	# generates tabling TODO background process
	#
	def generate
    members = Member.current_members
    times = 20..50
    assignments = generate_tabling_assignments(times, members)
    for t in times
      p t
      for m in assignments[t]
        p '       ' + m.name
      end
    end

   redirect_to :controller => 'tabling', :action => 'index'
	end

	#
	# clears all slots this week
	#
	def delete_slots
		begin
			clear_this_week_slots
			render :nothing => true, :status => 200, :content_type => 'text/html'
		rescue
			render :nothing => true, :status => 500, :content_type => 'text/html'
		end
	end
end

# input slots: tabling slots that you want to fill
# return assignments hash key: slot, value: array of members}
  def generate_tabling_assignments(times, members)
    """
    create assignment hash of timeslot (hour) to member list
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

  # return the hardest to work with member (least slots open)
  def get_MCV(unassigned, times)
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
    p 'mcv was '+mcv.name + ' with '+max_clashes.to_s
    return mcv
  end

  # least constrained value
  # slot with highest capacity after member has been assigned
  def get_LCV(assignments, member, times)
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

 

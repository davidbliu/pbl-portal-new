require 'chronic'
class TablingController < ApplicationController
	def index
		p current_member
		start_day = Chronic.parse('0 april 14', :context => :past)
		# start_day = tabling_start
		end_day = start_day+5.days
		#
		# using old controller
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
	end
	
	#
	# options for secretary to generate new tabling schedule
	#
	def options
	end

	#
	# generates tabling TODO background process
	#
	def generate
	end
end

#
# helper methods
#
def tabling_start
    if DateTime.now.cwday > 5 # If past Friday
      Chronic.parse("0 this monday")
    elsif DateTime.now.cwday == 1 # If Monday
      Chronic.parse("0 today")
    else
      Chronic.parse("0 last monday")
    end
end
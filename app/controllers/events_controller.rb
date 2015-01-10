require 'set'


class EventsController < ApplicationController

	def index
		# @events = Event.all.order(:start_time).reverse
		# redirect_to "events#list_events"
		redirect_to action: :manage
	end

	def delete
		@event = Event.find(params[:id])
		@event.destroy
		redirect_to "/events/manage"
	end

	def edit
		@event = Event.find(params[:id])
	end
	def update
		redirect_to '/events/manage'
	end


	def destroy
		event = Event.find(params[:id])
		p 'about to destroy this event'
		p event.name
		p 'destroying...'
		event.destroy
		redirect_to "events#manage"
		
	end

	#
	# list out events by semester, allow secretary to modify events
	# what would secretary need to change?
	# points, name
	#
	def manage
		@events_hash = Hash.new
		@semesters = Semester.all
		@semesters.unshift(Semester.current_semester)
		Semester.all.each do |semester|
			@events_hash[semester.name] = Event.where(semester_id: semester.id).order(:start_time)
		end


	end

	def list_google_events
		@google_events = get_google_events_list
		@synced_hash = Hash.new
		@existing_id_set = Set.new
		event_ids = Event.all.pluck(:google_id)
		event_ids.each do |event_id|
			@existing_id_set.add(event_id)
		end
	end

	def get_google_events_list(months = 6)
		@calendar_id = revert_google_calendar_id(pbl_events_calendar_id)
		max_time = DateTime.now+months.month
		all_events = google_api_request(
		  'calendar', 'v3', 'events', 'list',
		  {
			calendarId: @calendar_id,
			timeMin: beginning_of_fall_semester,
			timeMax: max_time,
		  }
		).data.items
		result = all_events
		all_events = process_google_events(all_events)
		return all_events
	end


	def pull_google_events
		@events = get_google_events_list
	end

	def sync_google_events
		all_events = get_google_events_list
		all_events.each do |e|
			event = Event.new
			if Event.where(google_id: e[:id]).length != 0
				event = Event.where(google_id: e[:id]).first
			else
				puts "event is ging to be created"
			end
			event.google_id = e[:id]
			event.start_time = e[:start_time]
			event.end_time = e[:end_time]
			event.name = e[:summary]
			if event.start_time > Semester.current_semester.start_date
				event.semester_id = Semester.current_semester.id
			end
			event.save
		end
		render json: all_events
	end

end

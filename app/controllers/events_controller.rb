class EventsController < ApplicationController

	def index
		@events = Event.all.order(:start_time).reverse
	end

	def list_google_events
		@google_events = get_google_events_list
		# @synced_google_events = Array.new
		# @unsynced_google_events
		@synced_hash = Hash.new
		@google_events.each do |e|
			if Event.where(google_id: e[:id]).length != 0
				@synced_hash[e[:id]] = false 
			else
				@synced_hash[e[:id]] = true
			end
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

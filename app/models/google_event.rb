class GoogleEvent < ActiveRecord::Base

	def time_string
	    self.start_time.strftime("%b %e, %Y from %k:%M") + " to "+self.end_time.strftime("%k:%M")
  	end

	def self.sync_events(google_events)
		google_events.each do |e|
        	event = GoogleEvent.new()
        	event.name = e.title
        	event.start_time = e.start_time
        	event.end_time = e.end_time
        	event.location = e.location
        	event.description = e.description
        	event.google_id = e.id
        	event.save!
        end
	end

	def self.google_datetime_fix(datetime)
	    time_string = datetime.date_time ? datetime.date_time.to_s : datetime.date.to_s
	    DateTime.parse(time_string)
	  end

	def self.pbl_events_calendar_id
		'8bo2rpf4joem2kq9q2n940p1ss@group.calendar.google.com'
	end
end

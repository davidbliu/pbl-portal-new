class GoogleEvent < ActiveRecord::Base

	def time_string
	    t = self.time
	    if not t 
	    	return '#'
	    end
	    day = t.strftime("%d")
	    month = t.strftime("%b")
	    year = t.strftime("%Y")
	    return month + " " + day + ", " + year
  end

	def self.sync_events(google_events)
		semesters = Semester.all
		google_events.each do |google_event|
			event = GoogleEvent.where(google_id: google_event.id).first_or_initialize
			event.name = google_event['summary']
			event.location = google_event['location']
			
			event.description = google_event['description']
			event.google_id = google_event['id']

			# pick the latest semester that starts before this event
			if google_event['start']
				event.time = self.google_datetime_fix(google_event['start'])
				semesters = Semester.all.order(:start_date)
				semesters.each do |semester|
					if event.time > semester.start_date
						event.semester_id = semester.id
					end
				end
			end
			puts event.to_yaml
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

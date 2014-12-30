task :pull_google_events => :environment do

	p 'hello there i will now pull all google events for ya brah'

	pbl_events_calendar_id = "8bo2rpf4joem2kq9q2n940p1ss@group.calendar.google.com"
	@calendar_id = revert_google_calendar_id(pbl_events_calendar_id)
	all_events = google_api_request(
	  'calendar', 'v3', 'events', 'list',
	  {
		calendarId: @calendar_id,
		timeMin: beginning_of_fall_semester,
		timeMax: (DateTime.now + 6.month),
	  }
	).data.items

	p 'here are all the eveents:'
end

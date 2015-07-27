class ParsePointsManager < ParseResource::Base
  fields :member_ids, :time, :member_emails

  def self.get_member_points(member, semester = Semester.current_semester)

  end

  def self.get_points_dict(semester = Semester.current_semester)
  	
  end

  # pull google events and write them into the cache?
  def self.pull_google_events
  	save = Array.new
  	# pull google events
	cal = Google::Calendar.new(:client_id     => ENV['GOOGLE_INSTALLED_CLIENT_ID'], 
	                   :client_secret => ENV['GOOGLE_INSTALLED_CLIENT_SECRET'],
	                   :calendar      => GoogleEvent.pbl_events_calendar_id,
	                   :redirect_url  => "urn:ietf:wg:oauth:2.0:oob" # this is what Google uses for 'applications'
	                   )
	cal.login_with_refresh_token(ENV['REFRESH_TOKEN'])
	now = Time.now.utc
	start_min = Time.now-5.months
	start_max = Time.now+1.year
	google_events = cal.find_events_in_range(start_min, start_max, :max_results=>1000)
	puts google_events
  end
end

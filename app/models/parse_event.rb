class ParseEvent < ParseResource::Base
  fields :name, :location, :start_time, :end_time, :description, :points, :google_id, :type, :semester_name

  """ convenience methods: a replacement for PointManager"""
  def self.attended_events(member, semester = ParseSemester.current_semester)
    
  end

  def self.current_events(semester = ParseSemester.current_semester) #TODO change this to the real semester
    ParseEvent.limit(10000).where(semester_name: semester.name)
  end

  def self.find_closest_semester(start_time, semesters)
    """ find closest semester within the list of semesters passed in. closest is defined as event after start of semester but nearest to start """
    semesters = semesters.sort_by{|x| x.start_time}
    best_semester = semesters[0]
    semesters.each do |semester|
      if semester.start_time < start_time
        best_semester = semester
      end
    end
    return best_semester
  end
  """ pull events from google"""
  def self.pull_from_google
  	save = Array.new
  	# pull google events
  	cal = Google::Calendar.new(:client_id     => ENV['GOOGLE_INSTALLED_CLIENT_ID'], 
                           :client_secret => ENV['GOOGLE_INSTALLED_CLIENT_SECRET'],
                           :calendar      => GoogleEvent.pbl_events_calendar_id,
                           :redirect_url  => "urn:ietf:wg:oauth:2.0:oob" # this is what Google uses for 'applications'
                           )
	cal.login_with_refresh_token(ENV['REFRESH_TOKEN'])
	now = Time.now.utc
    start_min = Time.now-2.years
    start_max = Time.now+1.year
    google_events = cal.find_events_in_range(start_min, start_max, :max_results=>1000)
    # get hash of existing events
    pehash = ParseEvent.limit(100000).all.index_by(&:google_id)
    num_saved = 0
    semesters = ParseSemester.all.to_a

    google_events.each do |e|
    	pe = ParseEvent.new
    	if pehash.keys.include?(e.id)
    		pe = pehash[e.id]
    	end
      if not (pe.name == e.title and pe.start_time = e.start_time and pe.end_time == e.end_time and pe.location == e.location and pe.description == e.description and pe.google_id == e.id and find_closest_semester(e.start_time, semesters).name == pe.semester_name)
        puts 'saving changes to ' + e.title
      	pe.name = e.title
      	pe.start_time = e.start_time
      	pe.end_time = e.end_time
      	pe.location = e.location
      	pe.description = e.description
      	pe.google_id = e.id
      	pe.type = 'google'
        pe.semester_name = find_closest_semester(e.start_time, semesters).name
        # pe.save
      	save << pe
      else
        puts 'no changes to ' + pe.name
      end
    end
    puts 'saving all events : '+ save.length.to_s
    ParseEvent.save_all(save)
  end
end
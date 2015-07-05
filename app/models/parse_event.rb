class ParseEvent < ParseResource::Base
  fields :name, :location, :start_time, :end_time, :description, :points, :google_id, :type


  """ pull events from google"""
  def self.pull_from_google
  	save = Array.new
  	# pull google events
  	cal = Google::Calendar.new(:client_id     => ENV['GOOGLE_INSTALLED_CLIENT_ID'], 
                           :client_secret => ENV['GOOGLE_INSTALLED_CLIENT_SECRET'],
                           :calendar      => GoogleEvent.pbl_events_calendar_id,
                           :redirect_url  => "urn:ietf:wg:oauth:2.0:oob" # this is what Google uses for 'applications'
                           )
	puts ENV['REFRESH_TOKEN']
	cal.login_with_refresh_token(ENV['REFRESH_TOKEN'])
	now = Time.now.utc
    start_min = Time.now-2.years
    start_max = Time.now+1.year
    google_events = cal.find_events_in_range(start_min, start_max, :max_results=>1000)
    # get hash of existing events
    pehash = ParseEvent.all.index_by(&:google_id)
    google_events.each do |e|
    	pe = ParseEvent.new
    	if pehash.keys.include?(e.id)
    		pe = pehash[e.id]
    	end
    	pe.name = e.title
    	pe.start_time = e.start_time
    	pe.end_time = e.end_time
    	pe.location = e.location
    	pe.description = e.description
    	pe.google_id = e.id
    	pe.type = 'google'
    	save << pe
    end
    puts 'saving all events : '+ save.length.to_s
    ParseEvent.save_all(save)
    puts 'saved '+ParseEvent.all.length.to_s
  end
end
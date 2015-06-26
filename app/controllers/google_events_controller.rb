class GoogleEventsController < ApplicationController

	def index
		# configure what dates of events to pull...
		@start_months_ago = 6
		if params[:start_months_ago]
			@start_months_ago = params[:start_months_ago]
		end

		@semester_hash = Semester.semester_hash
		if not session[:access_token]
			google_calendar_redirect
		else
			google_events = list_google_events
			GoogleEvent.sync_events(google_events)
			@events = GoogleEvent.all
			session.delete(:access_token)
		end

		

		# display events
	end

	def sync_events
		cal = Google::Calendar.new(:client_id     => ENV['GOOGLE_INSTALLED_CLIENT_ID'], 
                           :client_secret => ENV['GOOGLE_INSTALLED_CLIENT_SECRET'],
                           :calendar      => GoogleEvent.pbl_events_calendar_id,
                           :redirect_url  => "urn:ietf:wg:oauth:2.0:oob" # this is what Google uses for 'applications'
                           )
		puts ENV['REFRESH_TOKEN']
		cal.login_with_refresh_token(ENV['REFRESH_TOKEN'])


		now = Time.now.utc
        # Time.stubs(:now).returns(now)
        start_min = Time.now-2.years
        start_max = Time.now+1.year
        # cal.expects(:event_lookup).with("?timeMin=#{start_min.strftime("%FT%TZ")}&timeMax=#{start_max.strftime("%FT%TZ")}&orderBy=startTime&maxResults=25&singleEvents=true")
        google_events = cal.find_events_in_range(start_min, start_max, :max_results=>1000)
        # GoogleEvent.destroy_all
        # GoogleEvent.sync_all_events(google_events)
        GoogleEvent.sync_events(google_events)
        @events = GoogleEvent.all.sort_by{ |e| e.start_time }.reverse

		# @events = cal.events
	end

	""" pull events from Google """
	def google_calendar_redirect
	  google_api_client = Google::APIClient.new()
	  google_api_client.authorization = Signet::OAuth2::Client.new({
	    client_id: ENV.fetch('GOOGLE_CLIENT_ID'),
	    client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET'),
	    authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
	    scope: 'https://www.googleapis.com/auth/calendar',
	    redirect_uri: 'http://' + ENV['HOST'] + '/google_events/google_calendar_callback'
	  })
	  authorization_uri = google_api_client.authorization.authorization_uri
	  redirect_to authorization_uri.to_s
	end

	def google_calendar_callback
	  google_api_client = Google::APIClient.new()
	  google_api_client.authorization = Signet::OAuth2::Client.new({
	    client_id: ENV.fetch('GOOGLE_CLIENT_ID'),
	    client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET'),
	    token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
	    redirect_uri: 'http://' + ENV['HOST'] + '/google_events/google_calendar_callback',
	    code: params[:code]
	  })
	  response = google_api_client.authorization.fetch_access_token!
	  session[:access_token] = response['access_token']
	  redirect_to url_for(:action => :index)
	end

	def list_google_events(min_time=Time.now-6.months)
		google_api_client = Google::APIClient.new()
		  google_api_client.authorization = Signet::OAuth2::Client.new({
		    client_id: ENV.fetch('GOOGLE_CLIENT_ID'),
		    client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET'),
		    access_token: session[:access_token]
		  })

		  google_calendar_api = google_api_client.discovered_api('calendar', 'v3')

		  response = google_api_client.execute({
		    api_method: google_calendar_api.events.list,
		    parameters: {
		    	calendarId: GoogleEvent.pbl_events_calendar_id,
		    	timeMin: (min_time).iso8601
		    }
		  })

		  @merged_ids = Event.all.pluck(:google_id)
		  @events = response.data['items']
	end
end

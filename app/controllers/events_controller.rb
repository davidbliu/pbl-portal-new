require 'set'


class EventsController < ApplicationController

	def create
		@event = Event.new
		render 'edit'
	end

	def update

	end

	def edit
		@event = Event.find(params[:id])
	end


	def index
		# @events = Event.all.order(:start_time).reverse
		# redirect_to "events#list_events"
		redirect_to action: :manage
	end

	def attendance
		@event = Event.find(params[:id])
		@event_members = EventMember.where(event_id: @event.id)
		# @members = Member.where("id in (?)", event_members.pluck(:member_id))
	end

	def update_points
		@event = Event.find(params[:id])
		@points = params[:points]
		
		@event.points = @points.to_i
		@event.save

		response = Hash.new
		response['event_id'] = @event.id
		render json: response, :status => 200
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
		""" destroys event and redirects user to manage since manage is only place to destroy events from """
		event = Event.find(params[:id])
		p 'about to destroy this event'
		p event.name
		p 'destroying...'
		event.destroy
		redirect_to "events#manage"
	end


	
	def manage
		""" allows admin to set event points and change event details """
		@events = Event.this_semester.sort_by{|e| e.start_time}.reverse
	end
		
	# def list_google_events
	# 	""" compares google events with current events and allows admin to sync google event details with Events in portal""" 
	# 	@google_events = get_google_events_list
	# 	@existing_id_set = Event.all.pluck(:google_id).to_set
	# end

	def google_calendar_redirect
	  puts 'google calendar redirect running...'
	  google_api_client = Google::APIClient.new()

	  google_api_client.authorization = Signet::OAuth2::Client.new({
	    client_id: ENV.fetch('GOOGLE_CLIENT_ID'),
	    client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET'),
	    authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
	    scope: 'https://www.googleapis.com/auth/calendar.readonly',
	    redirect_uri: url_for(:action => :google_calendar_callback)
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
	    redirect_uri: url_for(:action => :google_calendar_callback),
	    code: params[:code]
	  })

	  response = google_api_client.authorization.fetch_access_token!

	  session[:access_token] = response['access_token']
	  p 'this is your access token '+session[:access_token]
	  redirect_to url_for(:action => :list_google_events)
	end

	def list_google_events
		if not session[:access_token]
			google_calendar_redirect
		end
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
		    	calendarId: pbl_events_calendar_id,
		    	timeMin: (Time.now-6.months).iso8601
		    }
		  })

		  @merged_ids = Event.all.pluck(:google_id)
		  @events = response.data['items']
	end

	def get_google_events_list(months = 6)
		max_time = DateTime.now+months.month
		all_events = google_api_request(
		  'calendar', 'v3', 'events', 'list',
		  {
			calendarId: pbl_events_calendar_id,
			timeMin: beginning_of_fall_semester,
			timeMax: max_time,
		  }
		).data.items
		puts 'this is the result'
		puts all_events
		result = all_events
		all_events = process_google_events(all_events)
		return all_events
	end

	def process_google_events(events, options={})
    results = []
    puts 'length of events is '+events.length.to_s
    events.each do |event|
      # start_time = google_datetime_fix(event.start)
      # end_time = google_datetime_fix(event.end)

      # if options[:this_week]
      #   start_time = this_week(start_time)
      #   end_time = this_week(end_time)
      # end

      results << {
        id: event.id,
        summary: event.summary,
        description: event.description,
      }
    end
    return results
    # return results.sort_by {|event| event[:start_time]}
  end

  def google_datetime_fix(datetime)
    time_string = datetime.date_time ? datetime.date_time.to_s : datetime.date.to_s
    DateTime.parse(time_string)
  end

	def merge_google_event
		google_id = params[:google_id]
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

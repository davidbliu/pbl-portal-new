class EventPointsController < ApplicationController

	def index
		@semester_events = Event.this_semester
	end

	def update_event_points
		# p params[:points_data]
		points_data = params[:points_data]
		points_data.each do |point_data|
			event = Event.find(point_data[1]['id'])
			points = point_data[1]['points'].to_i
			event.set_points(points)
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
end

class EventMembersController < ApplicationController

	def destroy
		@event_member = EventMember.find(params[:id])
		@event_member.destroy
		redirect_to :back
	end

	def update_event_points
		points_data = params[:points_data]
		points_data.each do |point_data|
			event = Event.find(point_data[1]['id'])
			points = point_data[1]['points'].to_i
			event.set_points(points)
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
end

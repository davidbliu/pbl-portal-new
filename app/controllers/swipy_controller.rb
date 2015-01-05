require 'json'

class SwipyController < ApplicationController

#
	def record_attendance
		# need this semesters events
		# keep a log of all the swipes
		# copy paste that shit somewhere
	end

	def record_event_member
		member = Member.where(swipy_data: params[:swipy_data]).first
		event = Event.find(params[:event_id])
		return_text = member.name+" attended "+ event.name
		render :json => return_text, :status => 200, :content_type => 'text/html'
	end

end

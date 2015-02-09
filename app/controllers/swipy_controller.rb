require 'json'
require 'twilio-ruby'
class SwipyController < ApplicationController

#
	def record_attendance
		# need this semesters events
		# keep a log of all the swipes
		# copy paste that shit somewhere

	end

	def record_event_member
		twilio_sid = ENV['twilio_sid']
		twilio_token = ENV['twilio_token']

		cal_id = params[:swipy_data].split("=")[0].last(8)
		p cal_id 

		begin
			member = Member.where(swipy_data: cal_id).first
			event = Event.find(params[:event_id])

			if member and event
				@semester_id = Semester.current_semester.id
				em = EventMember.where(event_id: event.id , member_id: member.id)
				p member.name
				if em.length>0
					return_text = member.name+ ' already registered for this event'
				else
					em = EventMember.create(semester_id: @semester_id, event_id: event.id, member_id:member.id)
					em.save
					return_text = member.name+" attended "+ event.name
				end


				
				# @client = Twilio::REST::Client.new twilio_sid, twilio_token 
	 			
				# @client.account.messages.create({
				# 	:to => member.phone,
				# 	:body => return_text,
				# 	:from => '+17149784696',    
				# })
				
				render :json => return_text, :status => 200, :content_type => 'text/html'
			else
				render :json => "no event or member: "+params[:swipy_data], :status => 200, :content_type => 'text/html'
			end
		rescue
			render :json => "errors with:  "+params[:swipy_data], :status => 200, :content_type => 'text/html'
		end
		
	end

end

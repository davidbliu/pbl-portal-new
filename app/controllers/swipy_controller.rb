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
		member = Member.where(swipy_data: params[:swipy_data]).first
		event = Event.find(params[:event_id])

		if member and event
			# send text message
			@client = Twilio::REST::Client.new twilio_sid, twilio_token 
 			
			@client.account.messages.create({
				:to => member.phone,
				:body => "Hi from the portal",
				:from => '+17149784696',    
			})
		end
		return_text = member.name+" attended "+ event.name + " text sent to "+member.phone
		render :json => return_text, :status => 200, :content_type => 'text/html'
	end

end

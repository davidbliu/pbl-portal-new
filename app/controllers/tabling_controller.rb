# require 'chronic'
require 'set'
class TablingController < ApplicationController

	before_filter :authorize

	def authorize
		if not current_member
			render 'layouts/authorize', layout: false
		else
			puts current_member.email
		end
	end

	def check
		slots = TablingHist.all.to_a
		@slots = slots

		rec = {}
		current_members = ParseMember.current_members
		current_members.each do |m|
			rec[m.email] = []
		end
		slots.each do |slot|
			members = slot.get_unconfirmed + slot.get_confirmed
			members.each do |m|
				rec[m] << slot.time
			end
		end
		@rec = rec

	end

	def switch_tabling
		email = params[:email]
		time1 = params[:time1].to_i
		time2 = params[:time2].to_i
		slots = ParseTablingSlot.all.to_a.index_by(&:time)
		# remove member from original slot
		slot1 = slots[time1]
		slot2 = slots[time2]
		slot1.member_emails = TablingHist.remove_item(slot1.member_emails, email)
		slot2.member_emails = TablingHist.push_item(slot2.member_emails, email)
		ParseTablingSlot.save_all([slot1, slot2])
		Rails.cache.write('tabling_schedule', nil)
		Rails.cache.write('tabling_hash', nil)
		render nothing:true, status:200
	end

	def whenisgood
		@commitments = {}
		Commitments.limit(1000).all.each do |commitment|
			commitments[commitment.member_email] = commitments.commitments
		end
	end
	def slot_guide
		@times = (0..167).to_a
	end
	def index
		@tabling_hash = TablingManager.tabling_schedule
		puts 'received tabling schedule'
		if not @tabling_hash
			redirect_to '/tabling/pick_slots'
		end
		@member_email_hash = ParseMember.current_members.index_by(&:email)
	end

	def pick_slots
		@confirmed = TablingHist.all.select{|x| x.confirmed.include?(current_member.email)}
		@unconfirmed = TablingHist.all.select{|x| x.unconfirmed.include?(current_member.email)}
	end

	def confirm_slot
		slot = TablingHist.where(time: params[:time].to_i).to_a[0]
		slot.confirmed = TablingHist.push_item(slot.confirmed, current_member.email)
		slot.unconfirmed = TablingHist.remove_item(slot.unconfirmed, current_member.email)
		saved = [slot]
		if params[:prev_time]
			prev_slot = TablingHist.where(time: params[:prev_time].to_i).to_a[0]
			prev_slot.unconfirmed = TablingHist.remove_item(prev_slot.unconfirmed, current_member.email)
			prev_slot.confirmed = TablingHist.remove_item(prev_slot.confirmed, current_member.email)

			# switch an unconfirmed from the slot to previous slot
			switch = slot.get_unconfirmed.sample
			slot.unconfirmed = TablingHist.remove_item(slot.unconfirmed, switch)
			prev_slot.unconfirmed = TablingHist.push_item(prev_slot.unconfirmed, switch)
			prev_slot.update_counts
			saved << prev_slot
		end
		slot.update_counts
		TablingHist.save_all(saved)
		redirect_to '/tabling/pick_slots'
	end

	def unconfirm_slot
		slot = TablingHist.where(time: params[:time].to_i).to_a[0]
		slot.unconfirmed = TablingHist.push_item(slot.unconfirmed, current_member.email)
		slot.confirmed = TablingHist.remove_item(slot.confirmed, current_member.email)
		slot.update_counts
		slot.save
		redirect_to '/tabling/pick_slots'
	end

	# displays all available slots that this member has not already been placed into
	def get_slots
		@prev_time = params[:prev_time]
		@slots = TablingHist.all.select{|x| x.get_unconfirmed.length > 0}
		@slots = @slots.select{|x| not x.unconfirmed.include?(current_member.email) and not x.confirmed.include?(current_member.email)} #TablingHist.all.sort_by{|x| x.time}
		@slots = @slots.sort_by{|x| x.time}
		@slots.each do |slot|
			puts slot.time.to_s + ': '+slot.unconfirmed.to_s
		end
	end

	def commitments
		@commitments = Commitments.get_commitments(current_member.email)
		@times_hash = TablingManager.times_hash
	end

	def save_commitments
		commitments = Commitments.where(member_email:current_member.email).to_a
		if commitments.length == 0
			c = Commitments.new(member_email: current_member.email)
		else
			c = commitments[0]
		end
		c.commitments = params[:commitments].split(',')
		c.save
		render nothing: true, status: 200

	end


  def manage
    @all_slots = TablingSlot.all
  end


	
	
	#
	# options for secretary to generate new tabling schedule
	#
	def options
		cms = Member.current_cms
	    officers = Member.current_chairs
	end

	#
	# generates tabling TODO background process
	#
	def generate
	    members = ParseMember.current_members
	    # times = 20..50
	    times = 20.times.map{ Random.rand(167) } 
	    assignments = ParseTablingManager.generate_tabling_schedule(times, members)
	   	redirect_to :controller => 'tabling', :action => 'index'
	end

	#
	# clears all slots this week
	#
	def delete_slots
		begin
			clear_this_week_slots
			render :nothing => true, :status => 200, :content_type => 'text/html'
		rescue
			render :nothing => true, :status => 500, :content_type => 'text/html'
		end
	end
end




 

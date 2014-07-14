class PointsController < ApplicationController
	def index
		@total_points = current_member.total_points
	end
	def rankings
		current_member = Member.where(name: "David Liu").first
		# semester_events
		attended_event_members = EventMember.where("event_id IN (?)", Event.this_semester.pluck(:id).collect{|i| i.to_s})
		attended_event_ids = attended_event_members.where(member_id: current_member.id).pluck(:event_id)
		@attended_events = Event.where("id in (?)", attended_event_ids.collect{|i| i.to_s})

		@attended_event_point_name_data = @attended_events.map{|e| {'event'=>e.name, 'points'=>e.points}}

		p 'calculating cm points'
		cm_points_list = current_member.cms.map{|cm| {'name' => cm.name, 'points' => cm.total_points}}
		@cm_points_list = cm_points_list.sort_by{|obj| obj['points']}.reverse

		p 'calculating all member points'
		points_list = Member.all.map{|m| {'name' => m.name, 'points' => m.total_points}}
		@points_list = points_list.sort_by{|obj| obj['points']}.reverse

	end

	def mark_attendance
		@semester_events = Event.this_semester
		@current_cms = Member.current_members
		# event_member_join = Event.join(curr)
		event_members = EventMember.all
		# @attended_dict = 

		@mappings_dict = Hash.new
		@current_cms.each do |cm|
			@mappings_dict[cm.id] = cm.attendance_id_mapping(@semester_events)
		end

	end

	#
	# cms can only view attendance
	#
	def view_attendance
		@semester_events = Event.this_semester
		@current_cms = Member.current_members
		# event_member_join = Event.join(curr)
		event_members = EventMember.all
		# @attended_dict = 

		@mappings_dict = Hash.new
		@current_cms.each do |cm|
			@mappings_dict[cm.id] = cm.attendance_mapping(@semester_events)
		end
	end

	#
	# save event members. input is (event_id, member_id) list
	# TODO assumes current semester
	#
	def update_attendance
		begin
			@semester_id = Semester.current_semester.id
			begin
				marked = params[:attendance_data]
				marked.keys.each do |key|
					em = EventMember.create(semester_id: @semester_id, event_id: marked[key]['event_id'], member_id:marked[key]['member_id'])
					em.save
				end
			rescue 
				p 'adding attendance failed'
			end
			begin
				unmarked = params[:remove_data]
				unmarked.keys.each do |key|
					em = EventMember.where(event_id: unmarked[key]['event_id'], member_id:unmarked[key]['member_id']).destroy_all
				end
			rescue
				p 'remove attendance failed'
			end
			
			render :nothing => true, :status => 200, :content_type => 'text/html'
		rescue
			render :nothing => true, :status => 500, :content_type => 'text/html'
		end
	end

	#
	# calculate apprentice rankings
	# TODO i just used view from old portal. should implement correctly
	#
	def apprentice

	end
end
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
			@mappings_dict[cm.id] = cm.attendance_mapping(@semester_events)
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
end
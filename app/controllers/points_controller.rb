class PointsController < ApplicationController

	before_filter :is_approved
	before_filter :is_officer, :only => :mark_attendance

	#
	# shows all point data ever
	# comprehensive master dayumn
	# probably run once, save, then from then on show an image until sexcretary runs this method again
	#
	def all_points
		current_member = @current_member
		@semesters = Semester.order(:start_date)
		@semester_point_hash = Hash.new
		@semesters.each do |semester|
			@semester_point_hash[semester.id] = Member.current_members(semester).map{|m| {'name'=>m.name, 'id'=>m.id, 'points'=>m.total_points(semester)}}
			@semester_point_hash[semester.id].sort! { |a,b| a['points'] <=> b['points'] }.reverse!
		end
		@semester_point_json = @semester_point_hash.to_json

	end


	def index
		# what events you attended
		@attended = PointManager.attended_events(current_member.id)
		# how many points you have
		@points = PointManager.points(current_member.id)
		# how many points everyone on your committee has
		@member_name_point_dict = PointManager.member_name_point_dict
		# rankings for pbl
	end
	def cooccurrence
		
	end
	def rankings
		current_member = @current_member
		# semester_events
		if current_member
			attended_event_members = EventMember.where("event_id IN (?)", Event.this_semester.pluck(:id).collect{|i| i.to_s})
			attended_event_ids = attended_event_members.where(member_id: current_member.id).pluck(:event_id)
			@attended_events = Event.where("id in (?)", attended_event_ids.collect{|i| i.to_s})

			@attended_event_point_name_data = @attended_events.map{|e| {'event'=>e.name, 'points'=>e.points}}

			p 'calculating cm points'
			cm_points_list = current_member.cms.map{|cm| {'id'=>cm.id, 'name' => cm.name, 'points' => cm.total_points, 'profile'=>cm.profile_url}}
			@cm_points_list = cm_points_list.sort_by{|obj| obj['points']}.reverse

			p 'calculating all member points'
			points_list = Member.current_cms.map{|m| {'id'=>m.id,'name' => m.name, 'points' => m.total_points, 'profile'=>m.profile_url}}
			@points_list = points_list.sort_by{|obj| obj['points']}.reverse

			#
			# calculate points for all committees
			#
			@committee_points = Array.new
			Committee.all.each do |committee|
				@committee_points << {"points"=>committee.rating, "committee"=> committee.name}
			end
			# current_member_ids = Member.current_members.pluck(:id)
			# current_events = Event.where(semester:Semester.current_semester)
			# current_event_ids = current_events.pluck(:id)
			# semester_attendance = EventMember.where("event_id in (?)", current_event_ids)
			# Committee.all.each do |committee|
			# 	# cm_ids = current_members.where()     .map(&:to_s)
			# 	cm_ids = CommitteeMember.where(committee_id: committee.id).where("member_id in (?)", current_member_ids).pluck(:member_id)
			# 	attended_event_ids = semester_attendance.where("member_id in (?)", cm_ids).pluck(:event_id)
			# 	attended_events = current_events.where("id in (?)", attended_event_ids)
			# 	total_points = 0
			# 	attended_events.each do |event|
			# 		total_points = total_points + event.points
			# 	end
			# 	@committee_points << {"committee" => committee.name, "points" => total_points}
			# end
		else
			@attended_events = []
			@attended_event_point_name_data = []
			@cm_points_list = []
			@points_list = []
		end


	end

	def mark_attendance
		# @semester_events = Event.this_semester.paginate(:page => params[:page], :per_page => 20)
		@semester_events = Event.this_semester.order(:start_time).page(params[:page]).per(17)
		# @semester_events = Event.this_semester
		if current_member.admin? 
			@current_cms = Member.current_members
		else
			@current_cms = Member.currently_in_committee(current_member.current_committee)
		end
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
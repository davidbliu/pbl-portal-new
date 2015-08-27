class PointsController < ApplicationController

	# before_filter :is_approved
	before_filter :is_officer, :only => :mark_attendance

	before_filter :authorize

	def authorize
		if not current_member
			render 'layouts/authorize', layout: false
		else
			puts current_member.email
		end
	end


	def index
		# what events you attended
		@attended = PointManager.attended_events(current_member.id)
		# how many points you have
		@points = PointManager.points(current_member.id)
		# how many points everyone on your committee has
		@member_name_point_dict = PointManager.member_name_point_dict
		# rankings for pbl (top 10 points)
		@top_cms = PointManager.top_cms.first(10)
	end

	def attendance
		emails = [current_member.email]
		@events = ParseEvent.order("start_time desc").where(semester_name: ParseSemester.current_semester.name).limit(10000000).all
		@members = ParseMember.current_members.select{|x| emails.include?(x.email)}

		ems = ParseEventMember.limit(100000000).all
		@event_members = Set.new
		ems.each do |em|
			@event_members.add(em.event_id + "," + em.member_email)
		end
	end

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

	def pull_google_events
		ParsePointsManager.pull_google_events
		render nothing: true, status: 200
	end


	
	def cooccurrence
		
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
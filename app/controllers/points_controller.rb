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
		# # what events you attended
		points = PointManager.get_points(current_member.email)
		@attended = points['attended'] #PointManager.attended_events(current_member.email)
		@points = points['points'] #@attended.map{|x| x.get_points}.inject{|sum,x| sum + x }
	end

	def update_attendance
		event_id = params[:event_id]
		email = params[:email]
		type = params[:type]
		type = PointManager.get_type(type)
		puts 'the type was '+type
		# save the data in parse
		ems = ParseEventMember.where(event_id: event_id).where(member_email: email).to_a
		if ems.length > 0
			em = ems[0]
		else
			em = ParseEventMember.new(event_id: event_id, member_email: email)
		end
		em.type = type
		em.save
		Rails.cache.write(email+'_points', nil)
		render nothing: true, status: 200
	end

	def attendance

		@events = ParseEvent.order("start_time asc").where(semester_name: ParseSemester.current_semester.name).all
		@ems = ParseEventMember.limit(1000000).all
		filter = params[:filter] ? params[:filter] : 'my_committee'
		if filter == 'all'
			@members = ParseMember.current_members.to_a
		elsif filter == 'me'
			@members = [current_member]
		elsif filter == 'chairs'
			@members = ParseMember.current_members.select{|x| x.position == 'chair'}
		elsif filter == 'all_cms'
			@members = ParseMember.current_members.select{|x| x.position == 'cm'}
		else
			@members = ParseMember.committee_members(current_member.committee).to_a
		end

		@event_members = ParseEventMember.hash(@ems)
		@keys = @event_members.keys
		@current_member = current_member
		puts @current_member
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
	# #
	# def update_attendance
	# 	begin
	# 		@semester_id = Semester.current_semester.id
	# 		begin
	# 			marked = params[:attendance_data]
	# 			marked.keys.each do |key|
	# 				em = EventMember.create(semester_id: @semester_id, event_id: marked[key]['event_id'], member_id:marked[key]['member_id'])
	# 				em.save
	# 			end
	# 		rescue 
	# 			p 'adding attendance failed'
	# 		end
	# 		begin
	# 			unmarked = params[:remove_data]
	# 			unmarked.keys.each do |key|
	# 				em = EventMember.where(event_id: unmarked[key]['event_id'], member_id:unmarked[key]['member_id']).destroy_all
	# 			end
	# 		rescue
	# 			p 'remove attendance failed'
	# 		end
			
	# 		render :nothing => true, :status => 200, :content_type => 'text/html'
	# 	rescue
	# 		render :nothing => true, :status => 500, :content_type => 'text/html'
	# 	end
	# end

	#
	# calculate apprentice rankings
	# TODO i just used view from old portal. should implement correctly
	#
	def apprentice

	end
end
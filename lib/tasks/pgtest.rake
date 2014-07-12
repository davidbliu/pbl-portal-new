



task :points_test => :environment do
	p 'hi'
	# em = EventMember.first
	# EventMember.find_each do |em|
	# 	p em.semester
	# Member.all.each do |mem|
	# 	p mem.name
	# 	begin
	# 		p mem.cms.pluck(:name)
	# 	rescue
	# 		p 'failed'
	# 	end
	# 	# p mem.total_points('all')
	# 	# p mem.tabling_slots
	# end
	# p Member.currently_in_committee(Committee.where(name: 'Historian').first).pluck(:name)

	# events = Event.all
	# events.each do |event|
	# 	'aaaa'
	# 	p event.attendance_rate(Committee.where(name: "Historian").first)
	# end
	p 'bye'
	p 'this semester is'
	p Semester.current_semester

end

task :rankings => :environment do
	current_member = Member.where(name: "David Liu").first
	# semester_events
	attended_event_members = EventMember.where("event_id IN (?)", Event.this_semester.pluck(:id).collect{|i| i.to_s})
	attended_event_ids = attended_event_members.where(member_id: current_member.id).pluck(:event_id)
	@attended_events = Event.where("id in (?)", attended_event_ids.collect{|i| i.to_s})

	@attended_events.all.each do |event| 
		p event.name + ": " + event.points.to_s + " points"
	end

	p 'calculating cm points'
	cm_points_list = current_member.cms.map{|cm| {'name' => cm.name, 'points' => cm.total_points}}
	@cm_points_list = cm_points_list.sort_by{|obj| obj['points']}.reverse
	p @cm_points_list

	p 'calculating all member points'
	points_list = Member.all.map{|m| {'name' => m.name, 'points' => m.total_points}}
	@points_list = points_list.sort_by{|obj| obj['points']}.reverse
	p @points_list
end

task :mark => :environment do
	# p Member.current_gm_ids
	@semester_events = Event.this_semester
		@current_cms = Member.current_members
		# event_member_join = Event.join(curr)
		event_members = EventMember.all
		# @attended_dict = 
		@current_cms.each do |cm|

			# @semester_events.each do |event|
			# 	if event_members.where(event_id: event.id.to_s).where(member_id: cm.id).length > 0
			# 		p 'yes'
			# 	else
			# 		p 'no'
			# 	end
			# end

			#
			# generate record of cm events
			#
			
			begin
				mapping = cm.attendance_mapping(@semester_events)
				p cm.name
				p mapping
				# p attended
			rescue
				name = cm.name
				p 'failed here'
				# p cm.name
				# current_member = Member.where(name: name).first
				# mems = EventMember.where(member_id: current_member.id)
				# for m in mems
				# 	if m.event_id.length > 5 or m.event_id == ""
				# 		p m.event_id
				# 		m.destroy
				# 	end
				# end

			end
		end
end

task :clean => :environment do
	current_member = Member.where(name: "Sammy Tong").first
	mems = EventMember.where(member_id: current_member.id)
	for m in mems
		p m.event_id
	end

	# p event_ids
end

task :tabling => :environment do
	# for m in Member.all
	# 	p m.name
	# 	p m.tabling_slots
	# end
	require 'chronic'
	# p tabling_start
	start_day = Chronic.parse('0 april 14', :context => :past)
	end_day = start_day+5.days
	week = (start_day..end_day)
	p start_day.class
	p end_day
	p week.class

	#
	# testing old controller
	#
    @tabling_slots = TablingSlot.where(
      "start_time >= :tabling_start and start_time <= :tabling_end",
      tabling_start: start_day,
      tabling_end: end_day,
    ).order(:start_time)

    if !@tabling_slots.empty?
      @earliest_time = @tabling_slots.first.start_time

      @tabling_days = Hash.new
      @tabling_slots.each do |tabling_slot|
        @tabling_days[tabling_slot.start_time.to_date] ||= Array.new
        tabling_day = @tabling_days[tabling_slot.start_time.to_date]

        tabling_day << tabling_slot
      end
    end

    p 'done'
    p @tabling_slots
    p @tabling_slots.length
end


def tabling_start
    if DateTime.now.cwday > 5 # If past Friday
      Chronic.parse("0 this monday")
    elsif DateTime.now.cwday == 1 # If Monday
      Chronic.parse("0 today")
    else
      Chronic.parse("0 last monday")
    end
end
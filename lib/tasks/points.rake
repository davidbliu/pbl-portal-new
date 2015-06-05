task :initialize_points => :environment do
  current_semester = Semester.current_semester
  p 'destroying all point managers for this semester'
  PointManager.where(semester_id: current_semester.id).destroy_all
  p 'creating a new point manager for this semester'
  pm = PointManager.new
  pm.semester_id = current_semester.id
  pm.save
end

task :g_event_members => :environment do
	test_member = Member.where(name: 'David Liu').first
	p test_member.name
	p PointManager.current_manager.event_members(test_member.id)
end

task :g_default_points => :environment do
	Event.all.each do |e|
		e.points = 5
		p e.name
		e.save
	end
end

task :g_random_points => :environment do
  times = 20..50
  members = Member.current_members
  p 'generating tabling'
  assignments = generate_tabling_assignments(times, members)

  generate_tabling_slots(assignments)
end


""" Testing Code """

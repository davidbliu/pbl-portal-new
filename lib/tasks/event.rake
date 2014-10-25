task :export_event_data => :environment do

	require 'csv'
	CSV.open("event_data.csv", "w") do |csv|
		csv << ["Name", "Date", "Attendance"]
		Event.all.each do |event|
			csv << [event.name, event.start_time, event.event_members.length]
			# p event.name
			# p event.start_time
			# p event.event_members.length
			# p 'next'
		end
	end
	# CSV.open("event_data.csv", "w") do |csv|
	  # csv << ["row", "of", "CSV", "data"]
	  # csv << ["another", "row"]
	  # ...
	  # csv << ["user_login", "user_email", "user_pass","display_name", "role"]

	  # Member.current_members.each do |member|
	  # 	csv << [member.email, member.email, "asdf",member.name, "editor"]
	  # end
	# end
end

task :points => :environment do
	CSV.open("points_data.csv", "w") do |csv|
		csv << ["Committee", "Total Points"]
		Committee.all.each do |committee|
			members = Member.currently_in_committee(committee)
			cpoints = 0
			members.each do |member|
				cpoints = cpoints + member.total_points
			end
			csv << [committee.name, cpoints]
		end
	end
end
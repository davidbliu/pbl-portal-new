task :export_players => :environment do
	require "yaml"
	members = Array.new
	Member.current_members.each do |m|
		mem = Hash.new
		mem['name'] = m.name
		mem['committee'] = m.current_committee.id
		mem['uid'] = m.uid
		members << mem
	end
	serialized_list = YAML::dump(members)
	File.open('member_dump_current.yaml', "w") do |file|
	    file.puts YAML::dump(members)
	end
	puts "members have been exported"
end

task :export_wp_users => :environment do
	require 'csv'
	CSV.open("wp_users.csv", "w") do |csv|
	  # csv << ["row", "of", "CSV", "data"]
	  # csv << ["another", "row"]
	  # ...
	  csv << ["user_login", "user_email", "user_pass","display_name", "role"]

	  Member.current_members.each do |member|
	  	csv << [member.email, member.email, "asdf",member.name, "editor"]
	  end
	end
end
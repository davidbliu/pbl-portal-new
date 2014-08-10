task :export_players => :environment do
	require "yaml"
	members = Array.new
	Member.current_members.each do |m|
		mem = Hash.new
		mem['name'] = m.name
		mem['committee'] = m.current_committee.id
		members << mem
	end
	serialized_list = YAML::dump(members)
	File.open('member_dump.yaml', "w") do |file|
	    file.puts YAML::dump(members)
	end
	puts "members have been exported"
end
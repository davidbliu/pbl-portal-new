task :flag_all_members => :environment do
	Member.all.each do |member|
		member.confirmation_status = 0
		member.save

	end
end

task :unflag_david => :environment do
	david = Member.where(name: "David Liu").first
	david.confirmation_status = 1 # requesting confirmation
	david.save

	kevin = Member.where(name: "Kevin Yin").first
	kevin.confirmation_status = 1
	kevin.save
	p david
end

task :confirm_lots_of_new => :environment do
	require "yaml"
	new_member_data = YAML.load_file('new_member_data.yaml')
	p new_member_data
	new_member_data.each do |md|
		# p md['id']
		# p md['position_name']
		member = Member.find(md['id'].to_i)
		committee = Committee.find(md['committee_id'].to_i)
		position_id = md['position_id'].to_i
		position_name = md['position_name']
		member.update_from_secretary(committee, position_id, position_name)
		member.confirmation_status = 2
		member.save
	end
	p 'done hopefully this worked'

end
task :p_pos => :environment do
	# david = Member.where(name: "David Liu").first
	# p david.primary_committee
	# p david.
end
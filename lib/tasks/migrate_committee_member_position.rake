namespace :migrate do
	task :committee_member_position => :environment do
		CommitteeMember.all.each do |cm|
			type = cm.committee_member_type
			if type.name == 'cm'
				cm.position_id = 2
			elsif type.name == 'chair'
				cm.position_id = 3
			elsif type.name == 'gm'
				cm.position_id = 1
			else 
				cm.position_id = 4
			end
			cm.save!
		end
	end

	task :position_check => :environment do
		puts 'there are currently '+ Member.current_chairs.length.to_s + ' chairs'
		puts 'there are currently '+ Member.current_officers.length.to_s + ' officers'
		puts 'there are currently '+ Member.current_cms.length.to_s + ' cms'
		puts 'there are currently '+ Member.current_execs.length.to_s + ' execs'
	end
end 

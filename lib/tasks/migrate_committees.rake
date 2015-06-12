namespace :migrate do
	task :committee_convenience => :environment do
		Committee.all.each do |c|
			puts c.name
		end
		puts 'this is gms: ' + Committee.gm.name
	end

	task :position_check => :environment do
		puts 'there are currently '+ Member.current_chairs.length.to_s + ' chairs'
		puts 'there are currently '+ Member.current_officers.length.to_s + ' officers'
		puts 'there are currently '+ Member.current_cms.length.to_s + ' cms'
		puts 'there are currently '+ Member.current_execs.length.to_s + ' execs'
	end
end 

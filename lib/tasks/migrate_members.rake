namespace :migrate do
	task :member_emails => :environment do
		email_hash = Hash.new
		email_set = Array.new
		duplicates = Array.new
		noemail = Array.new
		normal = Array.new
		puts 'getting duplicate emails'
		ParseMember.limit(10000).all.each do |pm|
			if not pm.email or pm.email == nil or pm.email == ''
				noemail << pm
			elsif email_set.include?(pm.email)
				duplicates << pm.email
			else
				email_set << pm.email
				normal << pm
			end
		end
		puts 'these are duplicated emails: '
		duplicates.each do |email|
			puts "\t" + email
		end
		puts 'these are no emails: '
		noemail.each do |m|
			puts "\t" + m.name
			puts "\t" + 'attended ' + EventMember.where(member_id: m.old_id).length.to_s + ' events'
		end

		puts 'these are normal members: '
		normal.each do |m|
			puts "\t" + m.name
			puts "\t" + 'attended ' + EventMember.where(member_id: m.old_id).length.to_s + ' events'
		end
	end

	task :archive_members => :environment do
		archived = Array.new
		active = Array.new
		Member.all.each do |member|
			""" people that never attended events will be archived """
			ems = EventMember.where(member_id: member.id)
			if ems.length == 0
				archived << member
			else 
				active << member
			end
		end 

		puts 'these are archived members: ' + archived.length.to_s
		archived.each do |m|
			puts "\t" + m.name
			puts "\t" + 'attended ' + EventMember.where(member_id: m.id).length.to_s + ' events'
		end

		puts 'these are active members: ' + active.length.to_s
		active.each do |m|
			puts "\t" + m.name
			puts "\t" + 'attended ' + EventMember.where(member_id: m.id).length.to_s + ' events'
		end
	end

	task :position_check => :environment do
		puts 'there are currently '+ Member.current_chairs.length.to_s + ' chairs'
		puts 'there are currently '+ Member.current_officers.length.to_s + ' officers'
		puts 'there are currently '+ Member.current_cms.length.to_s + ' cms'
		puts 'there are currently '+ Member.current_execs.length.to_s + ' execs'
	end
end 

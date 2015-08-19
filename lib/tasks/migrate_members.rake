namespace :migrate do

	task :set_positions => :environment do
		mhash = ParseMember.limit(100000).all.index_by(&:email)
		members = Array.new
		ParseCommitteeMember.limit(10000).all.each do |cm|
			member = mhash[cm.member_email]
			member.position = cm.position
			puts member.name
			puts cm.position
			members << member
		end
		ParseMember.save_all(members)
	end
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

	task :migrate_committee => :environment do
		# chash = Committee.all.index_by(&:id)
		save = Array.new
		ParseMember.limit(10000).all.each do |member|
			if not member.committee
				member.committee = 'GM'
				save << member
			end
		end
		puts 'saving ' + save.length.to_s 
		ParseMember.save_all(save)

	end

	""" creates members from the contact sheet and places them in their committee """
	task :import_from_contact_sheet => :environment do 
		require 'csv'
		'''["[WD]", "David Liu", "Web Development Chair", "davidbliu@berkeley.edu", "davidbliu@gmail.com", "davidbliu@gmail.com", "(714) 299-1786", "yes", "4th", "EECS"]'''

		m_email_hash = ParseMember.limit(10000).all.index_by(&:email)
		saved_members = Array.new
		saved_cms = Array.new
		chash = Committee.all.index_by(&:abbr)
		semester = ParseSemester.current_semester
		CSV.foreach("contact_sheet_fa15.csv") do |row|
			# puts 'row was ' + row.to_s
			committee = row[0]
			committee.slice! '['
			committee.slice! ']'
			# committee_id = 
			name = row[1]
			email = row[5]
			phone = row[6]
			major = row[9]
			year = row[8]
			puts committee
			if m_email_hash.keys.include?(email)
				member = m_email_hash[email]
			else
				member = ParseMember.new
			end
			if committee != 'XX'
				member.name = name
				member.email = email
				member.phone = phone
				member.major = major
				member.year = year
				member.role = 'Fall 2015 Officer'
				member.committee = committee
				puts 'saving this member ' + member.name
				puts member.valid?
				if not member.commitments
					member.commitments = ParseMember.default_commitments
				end
				# create a member and put them in committee
				saved_members << member
				saved_cms << ParseCommitteeMember.create(member_email: email, committee_abbr: committee, semester_name: semester.name, semester_id: semester.id)
			end
		end
		ParseCommitteeMember.save_all(saved_cms)
		ParseMember.save_all(saved_members)
	end
end 

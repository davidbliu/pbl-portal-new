task :import_fa15 => :environment do 
	require 'csv'
		'''["[WD]", "David Liu", "Web Development Chair", "davidbliu@berkeley.edu", "davidbliu@gmail.com", "davidbliu@gmail.com", "(714) 299-1786", "yes", "4th", "EECS"]'''

		m_email_hash = ParseMember.limit(10000).all.index_by(&:email)
		saved_members = Array.new
		# saved_cms = Array.new
		# chash = Committee.all.index_by(&:abbr)
		semester = ParseSemester.current_semester
		CSV.foreach("fa15_gms2.csv") do |row|
			# puts 'row was ' + row.to_s
			committee = row[0].strip
			committee.slice! '['
			committee.slice! ']'
			# committee_id = 
			name = row[1].strip
			email = row[2].strip
			puts '.....'
			puts name 
			puts email
			puts committee
			puts '...'

			if m_email_hash.keys.include?(email)
				member = m_email_hash[email]
			else
				member = ParseMember.new
				member.confirmation_status = 131
			end
			member.name = name.strip
			member.email = email.strip
			member.committee = committee.strip
			member.latest_semester = semester.name
			member.position = 'cm'
			member.confirmation_status = 777
			saved_members << member
		end
		puts 'SAVING MEMBERS>>>'
		saved_members.each do |member|
			puts member.name+','+member.email+','+member.committee
			member.save
		end
end

task :fa15_info => :environment do
	m_email_hash = ParseMember.limit(10000).all.index_by(&:email)
	CSV.foreach("fa15_member_info.csv") do |row|
		# puts 'row was ' + row.to_s
		email = row[0].strip
		phone = row[1] ? row[1].strip : ''
		year = row[3] ? row[3].strip : ''
		major = row[4] ? row[4].strip : ''
		if m_email_hash.keys.include?(email)
			member = m_email_hash[email]
			member.phone = phone
			member.year = year
			member.major = major
			member.save
		else
			puts email.to_s+' not in hash'
		end
		# puts '.....'
		puts email 
		# puts phone
		# puts year
		# puts major
		# puts '...'
	end
end

task :undo_import => :environment do
	ParseMember.destroy_all(ParseMember.limit(10000).where(confirmation_status:13).to_a)
end
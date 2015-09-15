task :import_fa15 => :environment do 
	require 'csv'
		'''["[WD]", "David Liu", "Web Development Chair", "davidbliu@berkeley.edu", "davidbliu@gmail.com", "davidbliu@gmail.com", "(714) 299-1786", "yes", "4th", "EECS"]'''

		m_email_hash = ParseMember.limit(10000).all.index_by(&:email)
		saved_members = Array.new
		# saved_cms = Array.new
		# chash = Committee.all.index_by(&:abbr)
		semester = ParseSemester.current_semester
		CSV.foreach("fa15_gms.csv") do |row|
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
				member.confirmation_status = 13
			end
			member.name = name.strip
			member.email = email.strip
			member.committee = committee.strip
			member.latest_semester = semester.name
			member.position = 'cm'
			saved_members << member
		end
		saved_members.each do |member|
			puts member.name+','+member.email+','+member.committee
			member.save
		end
end

task :undo_import => :environment do
	ParseMember.destroy_all(ParseMember.limit(10000).where(confirmation_status:13).to_a)
end
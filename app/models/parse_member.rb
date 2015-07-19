require 'set'
class ParseMember < ParseResource::Base

	fields :name, :provider, :uid, :google_id,
	:profile, :old_member_id, :remember_token, 
	:confirmation_status, :swipy_data, :registration_comment,
	:commitments, :old_id, :email, :phone, :major, :committee_id, :position_id, 
	:role, :year, :committee, :trello_id, :trello_token, :trello_member_id, :facebook_url


	def gravatar_url(size = 100)
		if self.facebook_url
			return facebook_url
		end
		gravatar_id = Digest::MD5.hexdigest(self.email.downcase)
    	return "http://gravatar.com/avatar/#{gravatar_id}.png?s="+size.to_s
	end

	def has_trello
		self.trello_id != nil and self.trello_id != '' and self.trello_token != nil and self.trello_token != '' and self.trello_member_id and self.trello_member_id != ''
	end
	""" WE USE EMAIL AS PRIMARY KEY: TODO SOME SORT OF VALIDATION CONSTRAINT """ 

	def self.hash 
		mhash = Rails.cache.read('parse_member_hash')
		if mhash != nil
			return mhash
		end
		mhash = ParseMember.limit(10000).all.index_by(&:id)
		Rails.cache.write('parse_member_hash', mhash)
		return mhash
	end

	def self.email_hash
		email_hash = Rails.cache.read('parse_member_email_hash')
		if email_hash != nil
			return email_hash
		end
		email_hash = ParseMember.limit(10000).all.index_by(&:email)
		Rails.cache.write('parse_member_email_hash', email_hash)
		return email_hash
	end
	
	def self.old_hash
		ParseMember.limit(10000).all.index_by(&:old_id)
	end



	""" get members by types """

	def self.current_members(semester = ParseSemester.current_semester)
		# cms = Rails.cache.read('current_members')
		# if cms != nil 
		# 	return cms
		# end
		mhash = ParseMember.email_hash
		keys = Set.new(mhash.keys)
		emails = ParseCommitteeMember.limit(1000).where(semester_name: semester.name).map{|x| x.member_email}
		cms = emails.select{|x| keys.include?(x)}.map{|x| mhash[x]}
		# Rails.cache.write('current_members', cms)
		return cms
	end

	def self.current_members_hash(semester = ParseSemester.current_semester)
		ParseMember.current_members.index_by(&:email)
	end

	# def self.current_officers(semester = ParseSemester.current_semester)
	# 	mhash = ParseMember.hash
	# 	officer_ids = ParseCommitteeMember.where(semester_id: semester.id).select{|x| x.position_id == 3 or x.position_id == 4}.map{|x| x.member_id}
		
	# 	officer_ids.map{|x| mhash[x]}
	# end

	#   def self.current_execs(semester = ParseSemester.current_semester)
	# 	mhash = ParseMember.hash
	# 	exec_ids = ParseCommitteeMember.where(semester_id: semester.id).where(position_id: 4).map{|x| x.member_id}
	# 	exec_ids.map{|x| mhash[x]}
	# end

	#   def self.current_chairs(semester = ParseSemester.current_semester)
	# 	mhash = ParseMember.hash
	# 	chair_ids = ParseCommitteeMember.where(semester_id: semester.id).where(position_id: 3).map{|x| x.member_id}
	# 	chair_ids.map{|x| mhash[x]}
	#  end

	 def self.default_commitments
		default_com = Array.new(168)
		168.times{|i| default_com[i] = 0}
		default_com
	end

	#   # excludes chairs
	# def self.current_cms(semester = ParseSemester.current_semester)
	# 	mhash = ParseMember.hash
	# 	current_committee_member_ids = ParseCommitteeMember.where(position_id: 2).where(semester_id: semester.id).map{|x| x.member_id}
	# 	current_committee_member_ids.map{|x| mhash[x]}
	# end

	""" specific member convenience methods """

	def self.member_committee_hash(semester = ParseSemester.current_semester)
		""" key is member id, value is committee_id """
		current_cms = ParseCommitteeMember.where(semester_id: semester.id)
		Hash[current_cms.map {|x| [x.member_id, x.committee_id]}]
	end

	def current_committee(semester = ParseSemester.current_semester)
		cm = ParseCommitteeMember.where(member_id: self.id, semester_id: semester.id)
		if cm.length == 0
		  return ParseCommittee.gm
		else
		  return ParseCommittee.find(cm.first.committee_id)
		end
	end

	""" permissions and roles """

	""" points and events attended"""

	""" migrate old Member model to ParseMember model """
	def self.migrate
		pms = Array.new
		Member.all.each do |m|
			puts m.name
			pm = ParseMember.new
			pm.name = m.name
			pm.provider  = m.provider
			pm.uid = m.uid
			pm.google_id = m.uid
			pm.profile = m.profile
			pm.remember_token = m.remember_token
			pm.confirmation_status = m.confirmation_status
			pm.swipy_data = m.swipy_data
			pm.registration_comment = m.registration_comment
			pm.commitments = m.commitments
			pm.old_id = m.id
			pm.email = m.email
			pm.major = m.major
			pms << pm
		end
		ParseMember.save_all(pms)
	end

	def self.update_committee
		members = Array.new
		mhash = ParseMember.hash
		ParseCommitteeMember.where(semester_id: ParseSemester.current_semester.id).each do |cm|
			member = mhash[cm.member_id]
			puts member.name
			member.committee_id = cm.committee_id
			member.position_id = cm.position_id
			member.role = CommitteeMemberPosition.positions[member.position_id-1].name
			members << member
		end
		ParseMember.save_all(members)
	end

	def self.merge_emails
		""" merges accounts into one by shifting over event_members, committee_members into one account and leaves blank duplicate accounts to be remove by remove_duplicate """
		duplicates = Array.new
		normal = Array.new
		email_set = Array.new
		email_hash = Hash.new
		ParseMember.limit(10000).all.each do |pm|
			if not pm.email or pm.email == nil or pm.email == ''
				puts pm.name + ' has no email'
			else
				if not email_hash.keys.include?(pm.email)
					email_hash[pm.email] = Array.new
				end
				email_hash[pm.email] << pm
				if email_set.include?(pm.email)
					duplicates << pm.email
				else
					email_set << pm.email
					normal << pm
				end
			end
		end
		puts 'these are duplicated emails: '
		duplicates.each do |email|
			puts "\t" + email
		end
		email_hash.keys.each do |email|
			accounts = email_hash[email]
			if accounts.length > 1
				puts 'handling ' + email
				firstid = accounts[0].old_id
				puts 'first id was '+firstid.to_s
				accounts.each do |account|
					if account.old_id != firstid
						account.destroy
					end
					""" transfer the ems and cms, commented out currently so can run deletion code """
					# puts "\t" + account.old_id.to_s + ' attended ' + EventMember.where(member_id: account.old_id).length.to_s + ' events'
					# ems = EventMember.where(member_id: account.old_id)
					# cms = CommitteeMember.where(member_id: account.old_id)
					# ems.each do |event_member|
					# 	event_member.member_id = firstid
					# 	if event_member.save
					# 		# puts "\t\t" + "transferred an em " + event_member.member_id.to_s
					# 		event_member.save!
					# 	end
					# end
					# cms.each do |cm|
					# 	cm.member_id = firstid
					# 	cm.save
					# end
	
				end
			end
		end

	end

	def self.remove_duplicate
	end
end

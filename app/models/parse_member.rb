class ParseMember < ParseResource::Base

	fields :name, :provider, :uid, :google_id,
	:profile, :old_member_id, :remember_token, 
	:confirmation_status, :swipy_data, :registration_comment,
	:commitments, :old_id, :email, :phone, :major, :committee_id, :position_id, 
	:role

	def self.hash 
		mhash = Rails.cache.read('parse_member_hash')
		if mhash != nil
			return mhash
		end
		mhash = ParseMember.limit(10000).all.index_by(&:id)
		Rails.cache.write('parse_member_hash', mhash)
		return mhash
	end
	
	def self.old_hash
		ParseMember.limit(10000).all.index_by(&:old_id)
	end



	""" get members by types """

	def self.current_members(semester = ParseSemester.current_semester)
		mhash = ParseMember.hash
		ids = ParseCommitteeMember.limit(1000).where(semester_id: semester.id).map{|x| x.member_id}
		ids.map{|x| mhash[x]}
	end

	def self.current_members_hash(semester = ParseSemester.current_semester)
		hash = Rails.cache.read('current_members_hash')
		if hash != nil
			return hash
		end

		hash = ParseMember.current_members.index_by(&:id)
		Rails.cache.write('current_members_hash', hash)
		return hash
	end

	def self.current_officers(semester = ParseSemester.current_semester)
		mhash = ParseMember.hash
		officer_ids = ParseCommitteeMember.where(semester_id: semester.id).select{|x| x.position_id == 3 or x.position_id == 4}.map{|x| x.member_id}
		
		officer_ids.map{|x| mhash[x]}
	end

	  def self.current_execs(semester = ParseSemester.current_semester)
		mhash = ParseMember.hash
		exec_ids = ParseCommitteeMember.where(semester_id: semester.id).where(position_id: 4).map{|x| x.member_id}
		exec_ids.map{|x| mhash[x]}
	end

	  def self.current_chairs(semester = ParseSemester.current_semester)
		mhash = ParseMember.hash
		chair_ids = ParseCommitteeMember.where(semester_id: semester.id).where(position_id: 3).map{|x| x.member_id}
		chair_ids.map{|x| mhash[x]}
	 end

	  # excludes chairs
	def self.current_cms(semester = ParseSemester.current_semester)
		mhash = ParseMember.hash
		current_committee_member_ids = ParseCommitteeMember.where(position_id: 2).where(semester_id: semester.id).map{|x| x.member_id}
		current_committee_member_ids.map{|x| mhash[x]}
	end

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
end

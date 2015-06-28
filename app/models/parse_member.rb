class ParseMember < ParseResource::Base

	fields :name, :provider, :uid, :google_id,
	:profile, :old_member_id, :remember_token, 
	:confirmation_status, :swipy_data, :registration_comment,
	:commitments, :old_id

	def self.hash 
		ParseMember.limit(10000).all.index_by(&:id)
	end
	
	def self.old_hash
		ParseMember.limit(10000).all.index_by(&:old_id)
	end



	""" get current members by types methods """

	def self.current_members(semester = ParseSemester.current_semester)
		mhash = ParseMember.hash
		ids = ParseCommitteeMember.limit(1000).where(semester_id: semester.id).map{|x| x.member_id}
		ids.map{|x| mhash[x]}
	end

	def self.current_members_hash(semester = ParseSemester.current_semester)
		ParseMember.current_members.index_by(&:id)
	end

	def self.current_officers(semester = ParseSemester.current_semester)
		chair_ids = CommitteeMember.(semester_id: semester.id).where('position_id > 2').pluck(:member_id)
		return Member.where('id IN (?)', chair_ids)
	end

	  def self.current_execs(semester = Semester.current_semester)
		chair_ids = CommitteeMember.where(semester: semester).where('position_id = 4').pluck(:member_id)
		return Member.where('id IN (?)', chair_ids)
	end

	  def self.current_chairs(semester = Semester.current_semester)
		chair_ids = CommitteeMember.where(semester: semester).where('position_id = 3').pluck(:member_id)
		return Member.where('id IN (?)', chair_ids)
	 end

	  # excludes chairs
	def self.current_cms(semester = Semester.current_semester)
		# chair_exec_tier = CommitteeMemberType.where("tier > 1").pluck(:id)
		# chair_ids = CommitteeMember.where(semester: semester).where('committee_member_type_id IN (?)', chair_exec_tier).pluck(:member_id)
		current_committee_member_ids = CommitteeMember.where(semester_id: semester.id).where('position_id = 2').pluck(:member_id)
		return Member.where('id IN (?)', current_committee_member_ids)#.where('id NOT IN (?)', Member.current_gm_ids).where('id NOT IN (?)', chair_ids)
	end
  

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
			pms << pm
		end
		ParseMember.save_all(pms)
	end
end

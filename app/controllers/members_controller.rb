class MembersController < ApplicationController
	def test
		# 
		# test all member functions
		# 
		me = Member.where(name: "David Liu").first
		# p me.committees
		# p me.primary_committee
		# p me.current_committee
		# p Member.current_members
		# p me.position
		# p me.tier
	end

	#
	# placeholder as i develop index
	#
	def all
		@semester = Semester.current_semester
		join = CommitteeMember.where(semester: @semester).joins(:member, :committee, :committee_member_type)
  		@current = join.map{|j| {'name'=>j.member.name,'email'=>j.member.email,'phone'=>j.member.phone,'position'=>j.committee_member_type.name, 'committee'=>j.committee.name, 'semester'=>@semester.name}}
		@alumni = Member.alumni.map{|a| {'name'=> a.name, 'email'=>a.email,'phone'=>a.phone,'committee'=>'alumni','position'=>'.','semester'=>'.' }}
	end

	def index
		@semester = Semester.current_semester
		join = CommitteeMember.where(semester: @semester).joins(:member, :committee, :committee_member_type)
  		@data = join.map{|j| {'name'=>j.member.name,'email'=>j.member.email,'phone'=>j.member.phone,'position'=>j.committee_member_type.name, 'committee'=>j.committee.name, 'semester'=>@semester.name}}
		#
		# better but bad
		#
		# current_members = Member.preload(:committee_members)
		# @committees = Committee.all
		# @curr_semester_id = Semester.current_semester.id
		# @data = Array.new
		# @semesters = Semester.all
		# current_members.each do |m|
		# 	begin
		# 		data = Hash.new
		# 		mems = m.committee_members.joins(:committee_member_type)
		# 		committee_member = mems.where(semester_id: @curr_semester_id).first
		# 		data['name'] = m.name
		# 		data['email'] = m.email
		# 		data['phone'] = m.phone
		# 		data['committee'] = @committees.find(committee_member.committee_id).name
		# 		data['position'] = committee_member.committee_member_type.name
		# 		data['semester'] = @semesters.where('id IN (?)' , mems.pluck(:semester_id)).pluck(:name)
		# 		@data << data
		# 	rescue
		# 		p 'failed'
		# 	end
		# end
		#
		# naive method?
		#
		# current_members = Member.all
		# @data = current_members.map{|m| {'name'=>m.name, 'committee'=>m.current_committee, 'position'=>m.position, 'semester'=>'.'}}
		# @current_members = Member.all
	end

end
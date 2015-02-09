class MembersController < ApplicationController
	
	# before_filter :is_approved, :only => :account
	#
	# allow to modify account
	# 
	before_filter :is_approved, :only => :all
	def index_committee
		# begin
		cid = params[:id]
		@committee = Committee.find(cid)
		@committee_members = Member.currently_in_committee(@committee)
		render 'index_committee'
		# rescue
		# 	render json: "you didnt input a committee id"
		# end
	end

	def manage
		@members = Member.all.order(:name)
	end

	def destroy
		@member = Member.find(params[:id])
		@member.destroy
		redirect_to :back
	end

	def reconfirm
		@member = Member.find(params[:id])
		@member.confirmation_status = 1
		@member.save!
		redirect_to '/members/manage'
	end
	def edit
		@member = Member.find(params[:id])
	end

	def update
	end
	#
	# see manage view
	# ajax -> get quick stats on member
	#
	def quick_stats
	end

	def show
		@member = Member.find(params[:id])
	end
	def account
	end
	def update_account
		 current_member.name = params[:name]
		 current_member.phone = params[:phone]
		 current_member.email = params[:email]
		 current_member.major = params[:major]
		 current_member.blurb = params[:blurb]
		 current_member.swipy_data = params[:swipy_data]
		 current_member.registration_comment = params[:registration_comment]
		 # if params[:reapprove]=='true'
		 # 	current_member.confirmation_status = 1
		 # end
		 current_member.save
		 # p params[:name]
		 # p params[:email]
		 # p params[:phone]
		 # p params[:reapprove]

		 render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def edit_confirmation
		@member = Member.find(params[:id])
	end
	def update_confirmation
		@member = Member.find(params[:id])
		registration_comment = params[:registration_comment]
		@member.registration_comment = registration_comment
		@member.confirmation_status = 1
		@member.save!
		render :json => "Confirmation status updated, please wait for secretary's approval", :status => 200, :content_type => 'text/html'
	end
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

	#
	# show unconfirmed members. let secretary confirm them
	#
	def confirm_new
		@committees = Committee.all
		@positions = CommitteeMemberType.all
		@unconfirmed = Member.where(confirmation_status: 1)
		@confirmed_this_semester = Member.where(confirmation_status: 2)

	end

	def process_new
		member_data = params[:member_data]
		p 'this is member_data'
		p member_data
		member_data.each do |key, md|
			# member = Member.find(md['id'].to_i)
			# p member
			member = Member.find(md['id'].to_i)
			committee = Committee.find(md['committee_id'].to_i)
			position_id = md['position_id'].to_i
			position_name = md['position_name']
			# p member.name
			# p 'thats all folks'
			member.update_from_secretary(committee, position_id, position_name)
			member.confirmation_status = 2
			member.save

		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def sign_up
		@member = params[:member]
	end

	def complete_sign_up
		member_data = params[:member_data]
		@member = Member.new
		@member.name = member_data['name']
		@member.email = member_data['email']
		@member.phone = member_data['phone']
		@member.registration_comment = member_data['registration_comment']
		@member.uid = cookies[:uid]
		@member.provider = cookies[:provider]
		@member.remember_token = Member.new_remember_token
		cookies[:remember_token] = @member.remember_token
		p @member
		@member.confirmation_status = 1
		@member.save
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	#
	# says to wait for secretary approval
	#
	def wait
	end

	def no_permission

	end
	
	def not_signed_in
	end

	def check
		@current_members = Member.current_members
		@current_officers = Member.current_chairs
		# @tablers = Member.current_members + Member.current_chairs
		@tablers = Array.new
	      Member.current_chairs.each do |cc|
	        @tablers << cc
      	end
	      Member.current_members.each do |cm|
	        @tablers << cm
      	end
	end
	#
	# shows only members from current semester
	#
	def index
		@semester = Semester.current_semester
		join = CommitteeMember.where(semester: @semester).joins(:member, :committee, :committee_member_type)
  		@data = join.map{|j| {'id'=>j.member.id,
  							  'name'=>j.member.name,
  							  'email'=>j.member.email,
  							  'phone'=>j.member.phone,
  							  'position'=>j.committee_member_type.name, 
  							  'committee'=>j.committee.name,
  							  'committee_id'=>j.committee.id, 
  							  'major'=>j.member.major}}.sort! {|a,b| a['name'] <=> b['name']}
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
require 'set'
class MembersController < ApplicationController
	
	# before_filter :is_approved, :only => :account
	#
	# allow to modify account
	# 
	# before_filter :is_approved, :only => [:all, :index_committee]

	before_filter :authorize

	def authorize
		if not current_member
			render 'layouts/authorize', layout: false
		else
			puts current_member.email
		end
	end

	def cache_featured_content
		content_hash = FeaturedContent.all.index_by(&:name)
		content_hash.keys.each do |key|
			Rails.cache.write(key, content_hash[key].content)
		end
		redirect_to '/'
	end

	def home
		@home_featured = Rails.cache.read('home_content')
		@current_member = current_member
		pin = 'Pin'
		@posts = PgPost.where("tags LIKE ?", "%#{pin}%").to_a.map{|x| x.to_parse}

		# @golinks = go_link_key_hash.values #ParseGoLink.limit(10000).all.to_a
		# @trending_links = @golinks.select{|x| x.type == 'trending'}
		# if current_member and current_member.email
			# @favorites = Set.new(GoLinkFavorite.where(member_email: current_member.email).map{|x| x.key})
			# @favorite_links = @golinks.select{|x| @favorites.include?(x.key)}
			# @favorites = (go_link_favorite_hash.keys.include?(current_member.email) ? Set.new(go_link_favorite_hash[current_member.email]) : Array.new)
			# @favorite_links = @golinks.select{|x| @favorites.include?(x.key)}
		# end
	end

	def notifications

		# get trello notifications
		trello_member_token = current_member.trello_token
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end
		begin
			me = Trello::Member.find(current_member.trello_member_id)
			@trello_notifications = me.notifications.map{|x| JSON.parse(x.to_json)}.select{|x| x['unread']}
			puts @notifications
		rescue
			@trello_notifications = Array.new
		end

		render 'notifications', :layout=>false
		
	end

	def me
		if not current_member
			render json: 'Please sign in to view this page', :status=>200
		else
			render 'me'
		end
	end

	def show
		@member = ParseMember.find(params[:id])
		render 'member'
	end
	
	#
	# shows only members from current semester
	#
	def index
		# @current_members = ParseMember.current_members.sort_by{|x| x.committee}
		# @current_members = current_members
		@current_members = ParseMember.current_members
		@current_member = current_member
		# @committee_hash = ParseCommittee.hash	
	end

	
	
	def profile
		@member = Member.find(params[:id])
		if @member != current_member
			redirect_to :controller=> 'members', :action=>'no_permission'
		end

	end

	def upload_profile
		@member = Member.find(params[:id])
		if @member != current_member
			render :nothing => true, :status => 500, :content_type => 'text/html'
		end
		current_member.profile = params[:image]
		current_member.save
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

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
	

end
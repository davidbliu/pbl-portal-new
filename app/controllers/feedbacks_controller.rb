class FeedbacksController < ApplicationController
	before_filter :is_admin, :only => [:index]
	def index
	end
	def add_feedback

	end

	def upload_feedback
		content = params[:content]
		p 'someone uploaded feedback'
		p content
		fb = Feedback.new
		fb.content = content
		fb.member_id = current_member.id
		fb.save!
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def thanks

	end
end

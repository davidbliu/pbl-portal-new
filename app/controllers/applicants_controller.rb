class ApplicantsController < ApplicationController
	def show
		@applicant = Applicant.find(params[:id])
	end

	def image
		@applicant = Applicant.find(params[:id])
	end

	def upload_image
		@applicant = Applicant.find(params[:id])
		@applicant.image = params[:image]
		@applicant.save!
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def update_payment
		@applicant = Applicant.find(params[:id])
		payment_status = params[:payment_status]
		@applicant.payment_status = payment_status
		@applicant.payment_committee_id = current_member.current_committee.id
		@applicant.save
		redirect_to '/applicants/'+@applicant.id.to_s
	end

end
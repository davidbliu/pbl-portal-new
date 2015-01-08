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
end
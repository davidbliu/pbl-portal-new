class ScavengerPhotosController < ApplicationController

	def confirm_photos
		@unconfirmed = ScavengerPhoto.where("points<1")
		@confirmed = ScavengerPhoto.where("points>1")
	end

	def confirm_photo
		@photo  = ScavengerPhoto.find(params[:id])
		points = params[:points].to_i
		@photo.points = points
		@photo.save!
		redirect_to :back
	end

	def destroy
		@photo  = ScavengerPhoto.find(params[:id])
		@photo.destroy!
		redirect_to :back
	end

end

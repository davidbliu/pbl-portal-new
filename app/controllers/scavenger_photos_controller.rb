class ScavengerPhotosController < ApplicationController

	def show
		@photo = ScavengerPhoto.find(params[:id])
	end
	def confirm_photos
		clean_photos_with_no_groups
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

	#destroys all photos with no groups
	def clean_photos_with_no_groups
		ScavengerPhoto.all.each do |photo|
			group = ScavengerGroup.where(id: photo.group_id)
			if group.length<1
				photo.destroy!
			end
		end
	end

	def destroy
		@photo  = ScavengerPhoto.find(params[:id])
		@photo.destroy!
		redirect_to :back
	end

end

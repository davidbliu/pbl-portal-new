class ScavengerGroupsController < ApplicationController

	def add_photo
		@group = ScavengerGroup.find(params[:id])
		theme = @group.theme
		photos = @group.photos
		if photos.length > 0
			@current_photo = photos.first
		end
	end

	def upload_photo
		@group = ScavengerGroup.find(params[:id])
		@group.photos.destroy_all
		photo = ScavengerPhoto.new
		photo.image = params[:image]
		photo.group_id = @group.id
		photo.save!
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
end

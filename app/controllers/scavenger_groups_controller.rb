class ScavengerGroupsController < ApplicationController

	def upload_photo
	end

	def add_photo
		@group = ScavengerGroup.find(params[:id])
	end

	def upload_photo
		@group = ScavengerGroup.find(params[:id])
		photo = ScavengerPhoto.new
		photo.image = params[:image]
		photo.group_id = @group.id
		photo.save!
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
end

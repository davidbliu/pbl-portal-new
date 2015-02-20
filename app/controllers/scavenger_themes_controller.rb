class ScavengerThemesController < ApplicationController



	def index
		@themes = ScavengerTheme.all
		@group = "Name"
		@theme_this_week = "Trees"
	end

	def add_photo
		@theme = ScavengerTheme.find(params[:id])
	end

	def upload_photo
		@theme = ScavengerTheme.find(params[:id])
		photo = ScavengerPhoto.new
		photo.image = params[:image]
		photo.member_id = current_member.id
		photo.save!
		@theme.scavenger_photos << photo
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
end

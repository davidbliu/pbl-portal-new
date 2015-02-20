class ScavengerThemesController < ApplicationController

	def index
		@themes = ScavengerTheme.all
	end

	def index2

	end


	def add_photo
		@theme = ScavengerTheme.find(params[:id])
	end

	def upload_photo
		@group = ScavengerGroup.find(params[:id])
		@theme = ScavengerTheme.find(@group.theme_id)
		photo = ScavengerPhoto.new
		photo.image = params[:image]
		# find this persons group and upload the photo for my group
		photo.group_id = @group.id
		photo.save!
		@theme.scavenger_photos << photo
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def generate_groups
		@theme = ScavengerTheme.find(params[:id])
		@theme.generate_groups
		@groups = @theme.get_groups
		# render :json=>@theme.get_groups, :status => 200, :content_type => 'text/html'
	end
end

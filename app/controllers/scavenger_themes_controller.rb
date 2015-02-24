class ScavengerThemesController < ApplicationController

	def index
		@themes = ScavengerTheme.all.order(:end_time).reverse
		@people = Member.current_cms+Member.current_chairs
		@people = @people.sort { |x,y| y.scavenger_points <=> x.scavenger_points }.first(15)
	end

	def show
		@theme  = ScavengerTheme.find(params[:id])
	end
	
	def manage
		@theme = ScavengerTheme.find(params[:id])
	end

	def gallery

	end

	def leaderboard
		

	end

	def personal
		@themes = ScavengerTheme.all.order(:end_time).reverse
		@groups = current_member.scavenger_groups
	end

	def index2

	end

	def generate_groups
		@theme = ScavengerTheme.find(params[:id])
		@theme.generate_groups
		@groups = @theme.get_groups
	end


	def confirm_photos
		@unconfirmed = ScavengerPhoto.where("confirmation_status=? or confirmation_status=?", nil, 0)
		@confirmed = ScavengerPhoto.where("confirmation_status!=? and confirmation_status!=?", nil, 0)
	end



end

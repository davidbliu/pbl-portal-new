class StaticController < ApplicationController
	def wd
		render 'wd', layout: false
	end
end
class StaticController < ApplicationController
	def wd
		render 'wd', layout: false
	end

	def extension
		render 'extension', layout: false
	end
end
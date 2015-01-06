require 'json'

class DeliberationsController < ApplicationController

#
	def index
		
	end

	def import_applicants

	end

	def handle_import_applicants

	end

	def manage

	end

	def results
		# clean_ranks
		@valid_committees = Deliberation.valid_committees
		@delib_id = params[:id]
		# @result = ApplicantRanking.where(deliberation_id: @delib_id)
		@deliberation = Deliberation.find(params[:id])
		# @deliberation.generate_default_rankings
		delib = @deliberation.algorithm_results
		@assignments = delib[0]
		@conflicts = delib[1]
		@shaky = delib[3]
		@bad = delib[4]
		@unassigned = delib[5]
		@remaining = delib[6]
	end

	def show
		# clean_ranks
		@valid_committees = Deliberation.valid_committees
		@delib_id = params[:id]
		# @result = ApplicantRanking.where(deliberation_id: @delib_id)
		@deliberation = Deliberation.find(params[:id])
		@applicants = @deliberation.applicants


	end
	
end

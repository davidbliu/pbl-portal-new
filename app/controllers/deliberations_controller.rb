require 'json'

class DeliberationsController < ApplicationController

#
	def index
		
	end

	def add_applicant
		@deliberation = Deliberation.find(params[:id])
	end

	def create_applicant
		@deliberation = Deliberation.find(params[:id])
	end

	def applicant_image
	end

	def upload_applicant_image
	end

	def import_applicants
		@deliberation = Deliberation.find(params[:id])
	end

	def rankings
		@deliberation = Deliberation.find(params[:id])
		@rankings = @deliberation.applicant_rankings.order(:applicant)
	end

	def update_rankings
		@deliberation = Deliberation.find(params[:id])
		@committee = Committee.find(params[:committee_id])
		ranking_data = params[:ranking_data] # array of dicts with applicant_id, rank_value
		ranking_data.each do |rank_data|
			# each looks something like this : ["13", {"applicant_id"=>"595", "rank_value"=>"50"}]
			rank_data = rank_data[1]
			# p rank_data['applicant_id']+' received '+rank_data['rank_value']
			rank_value = rank_data['rank_value'].to_i
			applicant = Applicant.find(rank_data["applicant_id"])
			@deliberation.update_ranking(applicant.id, @committee.id, rank_value)

		end
		# redirect_to '/deliberations/'+@deliberation.id.to_s+'/rank_applicants?committee_id='+@committee.id
		render :json => "Rankings have been updated! Refresh to confirm", :status => 200, :content_type => 'text/html'
	end

	def generate_default_rankings
		@deliberation = Deliberation.find(params[:id])
		@deliberation.generate_default_rankings
		redirect_to '/deliberations/'+@deliberation.id.to_s+'/rankings'
	end

	def settings
	end
	def update_settings
	end

	# handles applicant import
	def update_applicants
		@deliberation = Deliberation.find(params[:id])
		@deliberation.applicants.destroy_all
		applicant_data_string = params[:applicant_data]
		applicant_strings = applicant_data_string.split("\n")
		for string in applicant_strings
			data = string.split(",")
			# they have applied for committee membership in at least one committee
			if not (not data[1] and not data[2] and not data[3])
				applicant = Applicant.new
				applicant.name = data[0]
				if data[1]
					applicant.preference1 = data[1].to_i
				else
					applicant.preference1 = 1
				end
				if data[2]
					applicant.preference2 = data[2].to_i
				else
					applicant.preference2 = 1
				end
				if data[3]
					applicant.preference3 = data[3].to_i
				else
					applicant.preference3 = 1
				end
				applicant.deliberation_id = @deliberation.id
				applicant.fix_duplicate_preferences
				applicant.save
			end
		end

		render :json => @deliberation.name + " now has "+@deliberation.applicants.length.to_s+" applicants", :status => 200, :content_type => 'text/html'
	end

	def handle_import_applicants

	end

	def manage

	end

	def rank_applicants
		@deliberation = Deliberation.find(params[:id])
		p params[:committee_id]
		p 'that was committee id'
		@committee = Committee.find(params[:committee_id])
		@applicants = @deliberation.get_committee_applicants(@committee.id)
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

	def graph
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

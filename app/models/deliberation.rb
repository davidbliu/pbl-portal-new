class Deliberation < ActiveRecord::Base
  attr_accessible :name, :can_view_graph, :deliberation_settings
  serialize :deliberation_settings
  has_many :applicants, dependent: :destroy
  has_many :applicant_rankings, dependent: :destroy
  has_many :deliberation_assignments, dependent: :destroy
  belongs_to :semester, foreign_key: :semester_id


  def get_committee_applicants(committee_id)
  	first = self.applicants.where(preference1: committee_id)
  	second  = self.applicants.where(preference2: committee_id)
  	third = self.applicants.where(preference3: committee_id)
  	return first+second+third
  	# return self.applicants.where('preference1 LIKE :search OR preference2 LIKE search OR preference3 LIKE :search', search: committee_id)
  end

  def self.valid_committees
		valid = Array.new
		for c in Committee.all
			if not (c.name.include? "Exec" or c.name.include? "General" or c.name.include? "Internal")
				valid << c
			end
		end
		return valid
	end

  def capacity(committee)
  	if deliberation_settings and deliberation_settings[committee.id]
  		return deliberation_settings[committee.id].to_i
  	end
  	return 8
  end
  def width
  	if deliberation_settings and deliberation_settings["width"]
  		return deliberation_settings["width"].to_i
  	end
  	return 2
  end

  def applicants
  	return Applicant.where(deliberation_id: self.id)
  end

  def rankings
  	return ApplicantRanking.where(deliberation_id: self.id)
  end

  def assignments
  	return DeliberationAssignment.where(deliberation_id: self.id)
  end

  def applicant_ranks_by_committee(committee)
  	return ApplicantRanking.where(deliberation_id: self.id).where(committee: committee.id)
  end

  def clean_rankings
  	rankings = self.rankings
  	rankings.each do |r|
  		if r.applicant == nil
  			r.destroy
  		end
  	end
  end

  def clean_assignments
	assignments = self.assignments
  	assignments.each do |a|
  		if a.applicant == nil
  			a.destroy
  		elsif ApplicantRanking.where(applicant: a.applicant).where(committee: a.committee).where(deliberation_id: self.id).length == 0
  			a.destroy
  		end
  	end
  end

  def algorithm_results
  	clean_rankings
  	return deliberate
  end

  def relative_algorithm_results
  	clean_rankings
  	return deliberate_relative
  end

  def generate_default_rankings
  	# ApplicantRanking.where(deliberation_id: self.id).destroy_all
  	for a in self.applicants
		a.give_default_rankings
	end
  end

 def update_ranking(applicant_id, committee_id, new_value)
 	# ranking = self.applicant_rankings.where(applicant: applicant_id).where(committee: committee_id).first

 	p 'updating ranking'
 	ranking = self.applicant_rankings.where(applicant: applicant_id).where(committee: committee_id).first
 	ranking.value = new_value
 	ranking.save!
 	p ranking
 end
 def valid_committees
	valid = Array.new
	for c in Committee.all
		if not (c.name.include? "Exec" or c.name.include? "General" or c.name.include? "Internal")
			valid << c
		end
	end
	return valid
end
 def nodes_and_links
 	valid_committees = self.valid_committees
		nodes = Array.new
		for applicant in self.applicants
			node = Hash.new
			node["type"] = "applicant"
			node["value"] = applicant
			node["size"] = 5
			node["color"] = "black"
			node["value2"] = applicant.name
			if applicant.image
				node["image"] = applicant.image
			else
				node["image"] = "none"
			end
			nodes << node
		end
		for committee in valid_committees
			node = Hash.new
			node["type"] = "committee"
			node["value"] = committee.name
			node["value2"] = committee.name
			node["abbr"] = committee.abbr
			node["size"] = 10
			node["color"] = "red"
			nodes << node
		end
		links = Array.new
		for ranking in self.rankings
			c = Committee.find(ranking.committee)
			committee = c.name
			if valid_committees.include? c# dont want to include execs and gms
				applicant = self.applicants.find(ranking.applicant)
				anode = nodes.find { |l| l["value"] == applicant }
				anode_index = nodes.index(anode)
				cnode = nodes.find { |l| l["value"] == committee }
				cnode_index = nodes.index(cnode)

				link = Hash.new
				link["source"] = cnode_index
				link["source2"] = cnode["value"]
				link["target"] = anode_index
				link["target2"] = anode
				link["rank"] = ranking.value
				link["notes"] = ranking.notes
				link["id"] = ranking.id
				link["message"] = applicant.name+" "+committee
				link["info"] = applicant.id.to_s+" "+c.id.to_s
				if c.id == applicant.preference1
					link["color2"] = "blue"
				elsif c.id == applicant.preference2
					link["color2"] = "grey"
				else
					link["color2"] = "red"
				end
				if ranking.value == 50
					link["color"] = "yellow"
				else
					link["color"] = "blue"
				end
				# if the node is assigned already change its color to green
				if DeliberationAssignment.where(deliberation_id: self.id).where(committee: c.id).where(applicant: applicant.id).length > 0
					link["color"] = "green"
				end
				links << link
			end
		end

		data = Hash.new
		data["nodes"] = nodes
		data["links"] = links
		return data
	end


$shaky = Hash.new
$bad = Hash.new
def deliberate
	$shaky = Hash.new
	$bad = Hash.new
	capacity = 7
	applicants = self.applicants
	rankings = self.rankings
	rank_lists = Hash.new
	assignments = Hash.new
	unsure = Hash.new
	conflicts = Hash.new
	# initialize ranks list
	for c in self.valid_committees
		rank_lists[c] = Array.new
		unsure[c] = Array.new
		assignments[c] = Array.new
		ranks = self.applicant_ranks_by_committee(c).order(:value)
		for r in ranks
			if Applicant.find(r.applicant)
				rank_lists[c] << Applicant.find(r.applicant)
			end
		end
	end
	assignments_factored = factor_in_assignments(assignments, rank_lists)
	assignments = assignments_factored[0]
	rank_lists = assignments_factored[1]
	assignments = fill_committees(rank_lists, assignments, 8)
	count = 1
	conflicts = find_conflicts(assignments)
	while conflicts.length > 0
		assignments = resolve_conflicts(assignments, conflicts)
		p 'conflits resolved and now TRYING AGAIN'
		fill_committees(rank_lists, assignments, 8)
		conflicts = find_conflicts(assignments)
		# this should be removed later. if takes more than 10 iterations, stop
		count = count + 1
		if count > 10
			break
		end
	end
	for applicant in $shaky.keys
		for c in $shaky[applicant]
			unsure[c] << applicant
		end
	end
	unassigned = Array.new
	for a in self.applicants
		unassigned << a
	end
	# self.applicants
	assignments.keys.each do |k|
		assignments[k].each do |a|
			if unassigned.include? a
				unassigned.delete(a)
			end
			# unassigned << a
		end
	end
	return [assignments, conflicts, unsure, $shaky, $bad, unassigned, rank_lists]
end

def factor_in_assignments(assignments, rank_lists)
	assigned_people = Array.new
	# remove assigned people from rank lists
	# and add assigned people to assignments
	for a in self.assignments
		person = Applicant.find(a.applicant)
		committee = Committee.find(a.committee)
		assignments[committee] << person
		for key in rank_lists.keys
			if rank_lists[key].include? person
				rank_lists[key].delete(person)
			end
		end
	end
	return [assignments, rank_lists]
	# add assigned people to assignments
end

# fill each committee to its capacity. the capacity param doesn't get used, instead uses capacity method
def fill_committees(rank_lists, assignments, capacity)
	for c in assignments.keys
		while (assignments[c].length < self.capacity(c))
			if rank_lists[c].length > 0
				person = rank_lists[c][0]
				rank_lists[c].delete_at(0)
				rank = self.applicant_ranks_by_committee(c).where(applicant: person.id).first
				if rank.value == 50
					# you didn't want this person but added him because ran out of better people
					$bad[person] = Committee.find(rank.committee)
				end
				assignments[c] << person
			else
				# ran out of people so break out of loop
				break
			end
		end
	end
	return assignments
end
# return a list of conflicts
def find_conflicts(assignments)
	conflicts = Hash.new
	for key in assignments.keys
		for applicant in assignments[key]
			for k in assignments.keys
				if assignments[k].include? applicant and key != k
					if conflicts[applicant]
						if not conflicts[applicant].include? key
							conflicts[applicant] << key
						end
						if not conflicts[applicant].include? k
							conflicts[applicant] << k
						end
					else
						conflicts[applicant] = Array.new
						conflicts[applicant] << k
						conflicts[applicant] << key
					end
				end
			end
		end
	end
	return conflicts
end
def resolve_conflicts(assignments, conflicts)
	for applicant in conflicts.keys
		# decide which committee will get the applicant
		# if both committees rank applicant in the same tier use applicant preference
		# if one ranks applicant in a higher tier, give it to that committee
		best_rank = 100
		winning_committees = Array.new
		for c in conflicts[applicant]
			rank = self.applicant_ranks_by_committee(c).where(applicant: applicant.id).first
			if rank.value < best_rank and rank.value-best_rank < -1*self.width
				# you're the new winning committee
				winning_committees = Array.new
				winning_committees << c
				best_rank = rank.value
			elsif best_rank < rank.value and best_rank-rank.value< -1*self.width
				# youre too much worse than the best committee, do nothing
				puts "i lose"
			else
				# another you're in the same tier as another committee
				winning_committees << c
			end
		end

		if winning_committees.length == 1
			assignments = assign_and_remove(winning_committees[0], applicant, assignments)
		else
			# you need to go by applicant preference
			first_choice = Committee.find(applicant.preference1)
			second_choice = Committee.find(applicant.preference2)
			third_choice = Committee.find(applicant.preference3)
			if winning_committees.include? first_choice
				assignments = assign_and_remove(first_choice, applicant, assignments)
			elsif winning_committees.include? second_choice
				assignments = assign_and_remove(second_choice, applicant, assignments)
			else
				# this shouldn't happen but w/e
				assignments = assign_and_remove(third_choice, applicant, assignments)
			end
			# $shaky[applicant] = winning_committees
			winning_committees.each do |c|
				if not $shaky[applicant]
					$shaky[applicant] = Array.new
				end
				$shaky[applicant] << c
			end
		end
	end
	# end of loop over applicants in conflicts.keys
	return assignments
end

def assign_and_remove(committee, applicant, assignments)
	# you need to remove applicant from the other committee assignments
	for c in assignments.keys
		if c != committee
			if assignments[c].include? applicant
				assignments[c].delete(applicant)
			end
		end
	end
	return assignments
end
# deliberations code

end

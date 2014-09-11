task :flag_all_members => :environment do
	Member.all.each do |member|
		member.confirmation_status = 0
		member.save

	end
end

task :unflag_david => :environment do
	david = Member.where(name: "David Liu").first
	david.confirmation_status = 1 # requesting confirmation
	david.save

	kevin = Member.where(name: "Kevin Yin").first
	kevin.confirmation_status = 1
	kevin.save
	p david
end

task :p_pos => :environment do
	# david = Member.where(name: "David Liu").first
	# p david.primary_committee
	# p david.
end
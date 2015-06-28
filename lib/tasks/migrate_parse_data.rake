namespace :parse_migration do
	task :links => :environment do
		GoLink.all.each do |golink|
			puts golink.key
			plink = ParseGoLink.new
			plink.key = golink.key
			plink.url = golink.url
			plink.description = golink.description
			plink.old_id = golink.id
			plink.member_id = golink.member_id
			plink.save
		end
		puts 'done'
	end

	task :read => :environment do 
		puts ParseGoLink.where(:key => 'tabling')
	end
end 

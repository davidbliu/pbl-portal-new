namespace :cache do
	task :points => :environment do 
		puts 'caching points for each member'
		ParseMember.current_members.each do |member|
			if member.email
				points = Hash.new
				attended_events = PointManager.attended_events(member.email)
				pts = attended_events.map{|x| x.get_points}.inject{|sum,x| sum + x }
				points['points'] = pts
				points['attended'] = attended_events
				Rails.cache.write(member.email + '_points', points)
			end
		end
	end

	task :tabling => :environment do 
		puts 'caching tabling information for each member'
	end
end
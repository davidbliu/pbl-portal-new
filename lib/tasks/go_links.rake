namespace :go_links do
	task :populate  => :environment do
		GoLink.destroy_all
		go_hash = go_link_hash
		go_hash.keys.each do |key|
			golink = GoLink.create(key: key, url: go_hash[key], description: 'auto-generated from rake task')
			golink.save!
		end
		puts 'created '+GoLink.all.length.to_s + ' go links!'
	end
end 


def go_link_hash
	go_hash = Hash.new
	go_hash['tabling'] = "http://testing.berkeley-pbl.com/tabling"
	go_hash['points'] = "http://testing.berkeley-pbl.com/points"
	go_hash['neon'] = "https://drive.google.com/drive/folders/0BwLZUlGsG71OflJGRUphZHpyOEJNWXNIbnVXUFFMTkxBcXBIQWRBT0xxMVVKbnlHVjZTM28"
	return go_hash
end
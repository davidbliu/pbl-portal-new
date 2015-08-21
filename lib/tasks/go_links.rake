namespace :go_links do
	task :populate  => :environment do
		file = File.read('go_links.json') 
		go_links = JSON.parse(file)
		puts go_links
		go_links.each do |link|
			golink = ParseGoLink.new
			golink.url = link['url']
			golink.key = link['key']
			golink.description = link['description']
			golink.member_id = link['member_id']
			golink.old_id = link['id']
			golink.save
		end
		puts 'there are now ' + ParseGoLink.all.length.to_s + ' go links'
		# GoLink.destroy	all
		# go_hash = go_link_hash
		# go_hash.keys.each do |key|
		# 	golink = GoLink.create(key: key, url: go_hash[key], description: 'auto-generated from rake task')
		# 	golink.save!
		# end
		# puts 'created '+GoLink.all.length.to_s + ' go links!'
	end
	task :popular_links => :environment do
		h = ParseGoLinkClick.hash
		h.keys.each do |id|
			clicks = h[id]
			popular = PopularLink.where(parse_id:id).to_a
			begin
				golink = ParseGoLink.find(id)
			rescue
				puts 'deleted'
			end
			puts golink.key
			if popular.length > 0
				popular = popular[0]
				puts popular
				puts 'that was popular'
				popular.num_clicks = clicks.length
				popular.save
			else
				popular = PopularLink.create(parse_id: id, num_clicks: clicks.length, key: golink.key)
			end
		end
	end
end 


def go_link_hash
	go_hash = Hash.new
	go_hash['tabling'] = "http://testing.berkeley-pbl.com/tabling"
	go_hash['points'] = "http://testing.berkeley-pbl.com/points"
	go_hash['neon'] = "https://drive.google.com/drive/folders/0BwLZUlGsG71OflJGRUphZHpyOEJNWXNIbnVXUFFMTkxBcXBIQWRBT0xxMVVKbnlHVjZTM28"
	return go_hash
end
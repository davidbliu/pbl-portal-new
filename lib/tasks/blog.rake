task :export_blog => :environment do

	#
	# deets on blog see here
	# 'https://docs.google.com/document/d/18_PNWAgWSHBG1Mx5aR3Sv0b5AzGCbJM7jr4F01dVxzI/edit'
	#
	require "yaml"
	posts = Array.new
	OldPost.all.each do |post|
		newpost = Hash.new
		begin
			member = OldMember.find(post.member_id)
			newpost['email'] = member.email
			newpost['name'] = member.first_name+' '+member.last_name
			newpost['title'] = post.title
			newpost['body'] = post.body
			newpost['date'] = post.created_at
			p post.title
			posts << newpost
		rescue
			p 'NO OLD MEMMBER FOUND'
		end
	end
	# Member.current_members.each do |m|
	# 	mem = Hash.new
	# 	mem['name'] = m.name
	# 	mem['committee'] = m.current_committee.id
	# 	members << mem
	# end
	serialized_list = YAML::dump(posts)
	File.open('posts_dump.yaml', "w") do |file|
	    file.puts YAML::dump(posts)
	end
	puts "done exporting blogs"
end
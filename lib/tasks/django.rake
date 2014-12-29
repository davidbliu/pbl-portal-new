task :export_members => :environment do
	require 'yaml'
	members = Array.new
	Member.all.each do |member|
		mem = Hash.new
		mem['name'] = member.name
		mem['google_uid'] = member.uid
		mem['old_id'] = member.id
		members << mem
	end

	serialized_list = YAML::dump(members)
	File.open('rails_members.yaml', "w") do |file|
	    file.puts YAML::dump(members)
	end
end

task :import_videos => :environment do

	# Video.destroy_all
	p 'pre existing videos were destroyed'
	#
	# authenticate with youtube
	#
	dev_key = "AIzaSyCbVjHcjFjWxThf4ajuOVMTLXPqTbPXjAM"
	client = YouTubeIt::Client.new(:username=>"chriswong@berkeley.edu", :password=>"ruleofthirds", :dev_key => dev_key)
	all_videos = Array.new
	begin
		page = 1
		videos = client.my_videos(:page => page, :per_page => 50).videos
		while videos.length > 0 and page<2
			all_videos = all_videos + videos
			page = page + 1
			videos = client.my_videos(:page => page, :per_page => 50).videos
			p 'getting more videos, current video count is'
			p all_videos.length
		end
	rescue Exception => e
		p e
		p 'SOMETHING WENT WRONG'
	end

	problem_videos = 0
	min_json = Array.new
	all_videos.each do |video|
		min_video = Hash.new
		min_video["title"]=video.title
		min_video["unique_id"]=video.unique_id
		min_video["uploaded_at"]=video.uploaded_at
		begin
			min_video["whole"] = video
		rescue Exception => e
			p e
			problem_videos += 1
		end
		min_json << min_video
	end
	#
	# open a file
	#
	File.open("min_json.json","w") do |f|
	  f.write(min_json.to_json)
	end
	p problem_videos
	p 'that many videos have problems'
	# p 'thsee many were created '+Video.count.to_s

end
task :blah => :environment do
	all_videos = Array.new
	begin
		page = 1
		videos = client.my_videos(:page => page, :per_page => 50).videos
		while videos.length > 0
			all_videos = all_videos + videos
			page = page + 1
			videos = client.my_videos(:page => page, :per_page => 50).videos
			p 'getting more videos, current video count is'
			p all_videos.length
		end
	rescue Exception => e
		p e
		p 'SOMETHING WENT WRONG'
	end
	all_videos.each do |yvid|
		Video.insert_new_video(yvid)
	end
	p 'thsee many were created '+Video.count.to_s
	# render json: 'completed importing videos'
end

task :resolve_tags => :environment do
	Video.all.each do |video|
		title_data = video.resolve_tags_from_string
		if title_data["tags"].length == 0
			title_data["tags"] << "Untagged"
		end
		title_data["tags"].each do |tagname|
			if Tag.where(name: tagname).length < 1
				# tag doesnt exist yet
				newtag = video.tags.new
				newtag.name = tagname
				newtag.save
			end
			tag = Tag.where(name:tagname).first
			# insert into jointable
			join = VideoTag.where(video_id: video.id).where(tag_id: tag.id).first_or_create
			join.save
		end
	end
	p Tag.all
	p 'there are '+Tag.all.length.to_s+" tags"
end



task :clean_event_ids => :environment do
	EventMember.all.each do |em|
		if not em.event_id.to_i.to_s == em.event_id
			p em.event_id
			em.destroy
		end
	end
	EventPoints.all.each do |ep|
		if not ep.event_id.to_i.to_s == ep.event_id
			p ep.event_id
			p 'doesnt match'
			p ep.event_id.to_i.to_s
			ep.destroy
		end
	end
end
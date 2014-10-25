task :import_videos => :environment do

	Video.destroy_all
	p 'pre existing videos were destroyed'
	#
	# authenticate with youtube
	#
	dev_key = "AIzaSyCbVjHcjFjWxThf4ajuOVMTLXPqTbPXjAM"
	client = YouTubeIt::Client.new(:username=>"chriswong@berkeley.edu", :password=>"ruleofthirds", :dev_key => dev_key)
	p 'this is tclient'
	p client
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
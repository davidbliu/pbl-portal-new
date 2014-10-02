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
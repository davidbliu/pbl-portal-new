class ParseGoLinkDirectory< ParseResource::Base

	fields :go_link_id, :directory

	""" auto generate go link directories for testing. the usual process should be manual """
	def self.migrate
		ParseGoLinkDirectory.destroy_all
		puts 'migrating'
		golinks = ParseGoLink.all.to_a
		puts 'fetched go links'
		dirs = Array.new
		golinks.each do |golink|
			dir = ParseGoLinkDirectory.new
			dir.directory = '/'
			dir.go_link_id = golink.id
			dirs << dir
		end
		puts 'saving all directories created'
		ParseGoLinkDirectory.save_all(dirs)
	end
end

class ParseGoLink < ParseResource::Base
	fields :key, :url, :description, :member_id, :old_id, :type, :directory, :old_member_id, :num_clicks, :member_email

	def click_count
		if self.num_clicks != nil
			return self.num_clicks
		end
		return 0
	end
	def short_url(len = 50)
		if url.length > len
			return url.first(len) + "..."
		else
			return url
		end
	end

	def dir
		if self.directory and self.directory.include?('/')
			return self.directory
		end
		return '/'
	end


	def self.dir_hash
		# ParseGoLink.all.index_by(&:dir)
		dhash = Hash.new
		ParseGoLink.hash.values.each do |golink|
			dir = golink.dir 
			if not dhash.keys.include?(dir)
				dhash[dir] = Array.new
			end
			dhash[dir]  << golink 
		end
		return dhash
	end
	
	def self.directory_links(dir_name = '')
		hash = self.dir_hash
		if hash.keys.include?(dir_name)
			result = hash[dir_name]
			if result != nil
				return result
			end
		end
		return Array.new
	end

	def self.subdirectories(prefix = '/')
		lvl = prefix.split('/').select{|x| x != ''}.length
		puts 'level was '+lvl.to_s
		all_dirnames = Array.new
		dirnames = ParseGoLink.hash.values.uniq{|x| x.dir}.map{|x| x.dir}
		all_dirnames << '/'
		dirnames.each do |dirname|
			split = dirname.split('/').select{|x| x!= ''}
			sofar = ''
			for token in split
				sofar += '/' + token
				if not all_dirnames.include?(sofar)
					all_dirnames << sofar
				end
			end
		end
		all_dirnames.select{|x| x.start_with?(prefix) and x != prefix and x.split('/').select{|x| x != ''}.length == lvl+1}.sort
	end

	def get_type_image
		type = self.resolve_type
		return ParseGoLink.type_to_image(type)
	end

	def self.type_to_image(type)
		prefix = '/assets/'
		image_hash = Hash.new
		image_hash['document'] = 'docs-icon.png'
		image_hash['spreadsheets'] = 'sheets-icon.png'
		image_hash['facebook'] = 'facebook-icon.png'
		image_hash['trello'] = 'trello-logo.png'
		image_hash['youtube'] = 'youtube-icon.png'
		image_hash['box'] = 'box-icon.png'
		image_hash['piazza'] = 'piazza-icon.png'
		image_hash['flickr'] = 'flickr-logo.png'
		image_hash['git'] = 'git-icon.png'
		image_hash['other'] = 'pbl-logo.png'
		image_hash['drive'] = 'drive-icon.png'
		image_hash['instagram'] = 'instagram-logo.png'
		image_hash['presentation'] = 'sheets-icon.png'
		image_hash['form'] = 'forms-icon.png'
		return prefix + image_hash[type]
	end

	def resolve_type
		type = 'other'
		url = self.url
		if url.include?('docs.google.com/document')
			type = 'document'
		elsif url.include?('docs.google.com/spreadsheets')
			type = 'spreadsheets'
		elsif url.include?('trello.com')
			type = 'trello'
		elsif url.include?('flickr.com')
			type = 'flickr'
		elsif url.include?('box.com')
			type = 'box'
		elsif url.include?('youtube.com')
			type = 'youtube'
		elsif url.include?('facebook.com')
			type = 'facebook'
		elsif url.include?('github.com')
			type = 'git'
		elsif url.include?('piazza.com')
			type = 'piazza'
		elsif url.include?('drive.google.com')
			type = 'drive'
		elsif url.include?('instagram')
			type = 'instagram'
		elsif url.include?('docs.google.com/presentation')
			type = 'presentation'
		elsif url.include?('docs.google.com/forms')
			type = 'form'
		end
		return type
	end

	def updated_at_string
	    Date.parse(self.updated_at).strftime("%b %e, %Y")
  	end

	def self.hash
		hash = Rails.cache.read('go_link_hash')
		if hash != nil
			return hash
		end

		hash = ParseGoLink.limit(100000).all.index_by(&:id)
		Rails.cache.write('go_link_hash', hash)
		return hash
	end

	def self.key_hash
		l_hash = self.hash
		l_hash.values.index_by(&:key)
	end


	""" elasticsearch methods"""
	def self.import
		# create GoLink Objects
		GoLink.destroy_all
		puts 'requesting text hash...'
		parse_text_hash = ParseElasticsearchData.limit(100000).all.index_by(&:go_link_id)
		parse_text_hash_keys = parse_text_hash.keys
		puts 'received text hash!'
		ParseGoLink.limit(10000).all.each do |pgl|
			puts pgl.key
			gl = GoLink.new
			gl.key = pgl.key
			gl.url = pgl.url
			gl.description = pgl.description
			gl.member_id = pgl.member_id
			gl.parse_id = pgl.id
			if parse_text_hash_keys.include?(pgl.id)
				gl.text = parse_text_hash[pgl.id].text
			else
				gl.text = ''
			end
			gl.save
		end
		GoLink.import
		puts 'imported into elasticsearch index'
	end

	def self.search(search_term)
		#TODO dont include search items for deleted links
		GoLink.search(search_term)
	end
	
	""" catalogue methods DEPRECATED""" 
	def self.catalogue_by_resource_type
		types = Array.new
		types_keyword = Array.new

		types << 'Google Drive'
		types_keyword << 'drive.google.com'

		types << 'Google Docs'
		types_keyword << 'docs.google.com'

		types << 'Piazza'
		types_keyword << 'piazza.com'

		types << 'PBL Portal'
		types_keyword << '.berkeley-pbl.com'

		types << 'Google Forms'
		types_keyword << '/viewform'

		# types << 'other'
		# types_keyword << ''
		# set up result hash
		result = Hash.new
		types.each do |type|
			result[type] = Array.new
		end
		result['other'] = Array.new
		# populate result hash with list of links for each type
		link_hash = self.hash
		link_hash.keys.each do |id|
			url = link_hash[id].url
			matches = 0
			types.each_with_index do |type, index|
				if url.include?(types_keyword[index])
					result[type] << id
					matches = matches + 1
				end
			end
			if matches == 0
				result['other'] << id
			end
		end
		# remove empty partitions
		empty_partitions = Array.new
		result.keys.each do |partition|
			if result[partition].length < 1
				empty_partitions << partition
			end
		end
		empty_partitions.each do |partition|
			result.delete(partition)
		end
		return result
	end

	def self.catalogue_by_fix
		result = Hash.new
		link_hash = self.hash
		link_hash.keys.each do |id|
			key = link_hash[id].key
			chunks = key.split('-')
			chunks.each do |chunk|
				if not result.keys.include?(chunk)
					result[chunk] = Array.new
				end
				result[chunk] << id
			end
		end
		puts 'this is the resul'
		puts result
		return result
	end

	""" migration methods""" 
	def self.migrate_type
		golinks = ParseGoLink.limit(100000).all.to_a
		to_save = Array.new
		golinks.each do |golink|
			type = 'other'
			url = golink.url
			if url.include?('docs.google.com/document')
				type = 'document'
			elsif url.include?('docs.google.com/spreadsheets')
				type = 'spreadsheets'
			elsif url.include?('trello.com')
				type = 'trello'
			elsif url.include?('flickr.com')
				type = 'flickr'
			elsif url.include?('box.com')
				type = 'box'
			elsif url.include?('youtube.com')
				type = 'youtube'
			elsif url.include?('facebook.com')
				type = 'facebook'
			elsif url.include?('github.com')
				type = 'git'
			elsif url.include?('piazza.com')
				type = 'piazza'
			elsif url.include?('drive.google.com')
				type = 'drive'
			elsif url.include?('instagram')
				type = 'instagram'
			elsif url.include?('docs.google.com/presentation')
				type = 'presentation'
			end
			puts url + " : " + type
			golink.type = type
			to_save << golink
		end
		ParseGoLink.save_all(to_save)
	end

	def self.migrate_member_id
		puts 'not implemented yet'
	end
	def self.migrate_directory
		golinks = ParseGoLink.limit(100000).all.to_a
		save_array = Array.new
		golinks.each do |golink|
			golink.directory = '/'
			save_array << golink
		end
		ParseGoLink.save_all(save_array)
	end

	def self.update_num_clicks
		click_hash = ParseGoLinkClick.num_click_hash
		click_keys = click_hash.keys
		save = Array.new
		ParseGoLink.limit(100000).all.each do |golink|
			puts golink.key
			num_clicks = 0
			if click_keys.include?(golink.key)
				num_clicks = click_hash[golink.key]
			end
			golink.num_clicks = num_clicks
			save << golink
		end
		puts 'saving golinks...'
		ParseGoLink.save_all(save)
	end

	def self.migrate_member_email
		save = Array.new
		mhash = ParseMember.hash
		ParseGoLink.all.each do |golink|
			if golink.member_id != nil
				email = mhash[golink.member_id].email
				golink.member_email = email
				puts 'saving ' + golink.key + ' with ' + golink.member_email
				golink.save
			end
		end 
	end
end

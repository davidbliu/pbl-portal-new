class ParseGoLink < ParseResource::Base
	fields :key, :url, :description, :member_id, :old_id, :type, :directory, :old_member_id, :num_clicks, :member_email, :tags

	def updated_at_string
		t = self.updated_at + Time.zone_offset("PDT")
		t.strftime("%b %e, %Y at %l:%M %p")
	end

	def click_count
		if self.num_clicks != nil
			return self.num_clicks
		end
		return 0
	end

	def dir
		if self.directory and self.directory.include?('/')
			return self.directory
		end
		return '/'
	end

	def is_url_match(url)
		if self.url == url
			return true
		end
		if self.url.include?('docs.google.com')
			doc_id = self.url.split('/d/')[1].split('/')[0]
			if url.include?(doc_id)
				return true
			end
		end
	end

	def self.tag_hash
		golinks = ParseGoLink.hash.values
		thash = Hash.new
		golinks.each do |golink|
			if golink.tags
				golink.tags.each do |tag|
					if not thash.keys.include?(tag)
						thash[tag] = Array.new
					end
					thash[tag] << golink.key
				end
			end
		end
		return thash
	end

	""" cache clearing method """
	def self.clearcache
		Rails.cache.write("go_link_hash", nil)
		Rails.cache.write("go_link_key_hash", nil)
		Rails.cache.write("go_link_favorite_hash", nil)
	end
	""" check valid key, url, directory """
	def self.valid_key(key)
		if key == '' #or self.key_hash.keys.include?(key)
			return false
		end
		stripped = key.gsub('-', '')
		!stripped.match(/[^A-Za-z0-9]/)
	end

	def self.valid_url(url)
		url.start_with?('http')
	end

	def self.valid_directory(directory)
		if not directory.start_with?('/') 
			return false
		end
		if directory.scan('/').length > 3
			return false
		end
		if directory.end_with?('/')
			return false
		end
		splits = directory.split('/')[1..-1]
		if splits == nil or splits.length > 3
			return false
		end
		splits.each do |split|
			# puts split
			stripped = split.gsub('-', '')
			if not !stripped.match(/[^A-Za-z0-9]/)
				return false
			end
		end
		return true
	end

	""" methods to rename  directories """
	def self.rename_directory(directory, new_directory)
		""" cache must be invalidated after calling this method """
		if self.valid_directory(new_directory)
			golinks = ParseGoLink.hash.values
			affected = golinks.select{|x| x.dir.start_with?(directory)}

			changed_directory = Array.new
			affected.each do |golink|
				additional = golink.dir.split(directory)[-1] ? golink.dir.split(directory)[-1] : ""
				new_dir = ParseGoLink.valid_directory(new_directory + additional) ? new_directory + additional : golink.dir
				puts 'old: '+golink.dir + "\t" + 'new: ' + new_dir
				golink.directory = new_dir
				changed_directory << golink
			end

			puts 'Saving '+ changed_directory.length.to_s + ' links'
			ParseGoLink.save_all(changed_directory)
			return true
		else
			puts 'invalid directory'
			return false
		end
	end
	def self.create_directory(directory)
		if self.valid_directory(directory)
			uuid = SecureRandom.random_number(100000000).to_s
			auto = ParseGoLink.new(key: "auto-generated-"+uuid, url: 'http://www.google.com', directory: directory, description: 'auto generated from creating new directory')
			return auto.save
		else
			return false
		end
		
	end
	""" methods to help get directory tree """
	def self.one_ply(directories)
		directories.map{|x| '/' + x.split('/').select{|y| y!= ""}[0]}.uniq.sort
	end
	def self.two_ply(directories)
		directories.select{|x| x.scan('/').length > 1}.map{|x| '/' + x.split('/').select{|y| y!= ""}[0] + '/' + x.split('/').select{|y| y!= ""}[1]}.uniq.sort
	end
	def self.three_ply(directories)
		three_ply_dirs = Array.new
		directories.select{|x| x.scan('/').length > 2}.each do |dir|
			splits = dir.split('/').select{|x| x!= ""}
			three_ply_dirs << '/' + splits[0] + '/' + splits[1] + '/' + splits[2]
		end
		return three_ply_dirs.sort
	end
	def self.n_ply_tree(directories)
		""" currently only returns a three ply tree"""
		one_level = self.one_ply(directories)
		two_level = self.two_ply(directories)
		three_level = self.three_ply(directories)
		one_to_two = Hash.new
		two_level.each do |two|
			two_root = '/' + two.split('/').select{|x| x!= ''}[0]
			if not one_to_two.keys.include?(two_root)
				one_to_two[two_root] = Array.new
			end
			one_to_two[two_root] << two
		end
		two_to_three = Hash.new
		three_level.each do |three|
			split = three.split('/').select{|x| x!= ''}
			three_root = '/' + split[0] + '/' + split[1]
			if not two_to_three.keys.include?(three_root)
				two_to_three[three_root] = Array.new
			end
			two_to_three[three_root] << three
		end
		""" sort all subdirectories """
		return [one_to_two, two_to_three]
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

	def self.directories(golinks)
		golinks.map{|x| x.dir}.uniq
	end
	def self.all_directories(golinks)
		dirs = self.directories(golinks)
		return self.one_ply(dirs) + self.two_ply(dirs) + self.three_ply(dirs)
	end

	def self.directory_hash(golinks)
		dhash = Hash.new
		golinks.each do |golink|
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
		# puts 'requesting text hash...'
		parse_text_hash = ParseElasticsearchData.limit(100000).all.index_by(&:go_link_id)
		parse_text_hash_keys = parse_text_hash.keys
		# puts 'received text hash!'
		ParseGoLink.limit(10000).all.each do |pgl|
			# puts pgl.key
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
		# puts 'imported into elasticsearch index'
	end

	def self.search(search_term)
		#TODO dont include search items for deleted links
		# GoLink.search(search_term)
		keys = Array.new
		results = GoLink.search(search_term, :size=>1000).results.results
		results.each do |result|
			keys << result._source["key"]
		end
		return keys
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

	def self.migrate_tags
		golinks = Array.new
		ParseGoLink.limit(100000).all.each do |golink|
			tags = golink.dir.split('/').select{|x| x != ""}
			
			
			if golink.tags == nil
				puts golink.key
				golink.tags = tags
				golinks << golink
			end
		end
		ParseGoLink.save_all(golinks)
		return true
	end
end

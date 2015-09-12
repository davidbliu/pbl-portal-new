require 'timeout'
class ParseGoLink < ParseResource::Base
	fields :key, :url, :description, :member_id, :old_id, :type, :directory, 
	:old_member_id, :num_clicks, :member_email, :permissions, :parse_id, :rating, :votes, :tags


	def get_num_clicks
		self.num_clicks ? self.num_clicks : 0
	end
	def can_edit(email)
		if self.member_email == email
			return true
		end
		admin_emails = ['davidbliu@gmail.com', 'akwan726@gmail.com', 'emilyyliu96@gmail.com', 'eric.quach@berkeley.edu']
		if admin_emails.include?(email)
			return true
		end
		return false
	end
	def get_parse_id
		return self.parse_id ? self.parse_id : self.id
	end

	def get_rating
		(self.rating and self.rating > 0) ? self.rating : 0
	end

	def get_votes
		self.votes ? self.votes : 0
	end

	def get_tags
		self.tags ? self.tags : []
	end

	def add_tag(tag)
		# add to self array of tags
		# add to tag histogram
	end

	def remove_tag(tag)
	end

	def log_view(member)
		click = ParseGoLinkClick.new
		click.member_email = member ? member.email : 'noemail'
		click.key = self.key
		click.time = Time.now
		click.golink_id = self.id
		click.save
		""" save num clicks in the link itself """
		num_clicks = self.num_clicks ? self.num_clicks + 1 : 1
		self.num_clicks = num_clicks
		self.save
		""" save into the GoLink object """
		gl = GoLink.where(parse_id: self.id).first
		gl.num_clicks = num_clicks
		gl.save
	end
	""" permissions include Only Me, Only Officers, Only Execs, Only PBL, Public""" 
	def self.dalli_client
		options = { :namespace => "app_v1", :compress => true }
    	dc = Dalli::Client.new(ENV['MEMCACHED_HOST'], options)
    	return dc
	end

	def get_permissions
		(self.permissions and self.permissions != '') ? self.permissions : 'Only Officers'

	end
	def get_creator
		(self.member_email and self.member_email != '') ? self.member_email : 'noemail'
	end

	def can_view(member)
		if member == nil
			return self.get_permissions == 'Anyone'
		end
		if self.get_permissions == 'Anyone'
			return true
		end

		if self.get_permissions == 'Only PBL'
			# puts 'retuning this result'
			# puts (member and member.email != nil and member.email != '')
			return (member and member.email != nil and member.email != '')
		end

		if self.get_permissions == 'Only Officers'
			return (member and member.position != nil and (member.position == 'chair' or member.position == 'exec'))
		end

		if self.get_permissions == 'Only Execs'
			return (member and member.position != nil and member.position == 'exec')
		end

		if self.get_permissions == 'Only My Committee'
			return true
		end
		# you can view if you created the link
		if self.member_email == member.email
			return true
		end
	end

	def self.cache_golinks
		"""caches go links in a separate thread """
		Thread.new{
			dc = DalliManager.dalli_client
			status = Timeout::timeout(30) {
				puts 'thread has spawned'
				if dc.get('golinks_already_caching') == nil
					dc.set('golinks_already_caching', true)
					puts 'caching golinks'
					golinks = ParseGoLink.limit(1000000).all.to_a
					dc.set('golinks', golinks)
					golink_key_hash = Hash.new # key to list of golinks
					keyset = Set.new
					golinks.each do |golink|
						if not keyset.include?(golink.key)
							golink_key_hash[golink.key] = Array.new
							keyset << golink.key
						end
						golink_key_hash[golink.key] << golink 
					end
					dc = DalliManager.dalli_client
					dc.set('golink_key_hash', golink_key_hash)
					dc.set('golinks_already_caching', nil)
					puts 'finished caching golinks'
				end
				puts 'thread exiting'
			}

		}
	end

	def self.cached_golinks
		DalliManager.dalli_client.get('golinks')
	end

	def self.cache_permissions
		status = Timeout::timeout(30){
			puts 'caching permissions'
		}
	end 

	def self.save_permissions_into_memcached

	end

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
		if self.url.include?('docs.google.com') and self.url.include?("/d/")
			begin
				doc_id = self.url.split('/d/')[1].split('/')[0]
				if url.include?(doc_id)
					return true
				end
			rescue
				return false
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
		if url == nil
			return type
		end

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
		puts 'importing go links'
		# create GoLink Objects
		# GoLink.destroy_all
		# puts 'requesting text hash...'
		parse_text_hash = ParseElasticsearchData.limit(100000).all.index_by(&:go_link_id)
		parse_text_hash_keys = parse_text_hash.keys
		# puts 'received text hash!'
		ParseGoLink.limit(100000).all.each do |pgl|
			print '.'
			gl = GoLink.where(key: pgl.key, parse_id: pgl.id).first_or_create
			gl.url = pgl.url
			gl.description = pgl.description
			gl.member_id = pgl.member_id
			gl.permissions = pgl.permissions
			gl.member_email = pgl.member_email
			gl.tags = pgl.tags
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

	# results = GoLink.search(query: {query_string: {query: search_term, fields: ['key^10', 'data', 'description', 'text'], fuzziness:1}}, :size=>100).results

	def self.search(search_term)
		results = GoLink.search(query: {multi_match: {query: search_term, fields: ['key^3', 'tags^2', 'description', 'text', 'url', 'member_email'], fuzziness:1}}, :size=>100).results
		return self.search_results_to_golinks(results)
	end

	def self.search_my_links(search_term, email)
		results = GoLink.search(query: {multi_match: {query: search_term, fields: ['key^3', 'tags^2', 'description', 'text', 'url', 'member_email'], fuzziness:1}}, :size=>100).results
		return self.search_results_to_golinks(results)
	end

	def self.search_results_to_golinks(results)
		golinks = Array.new
		results.each do |result|
			data =  result._source
			golinks << ParseGoLink.new(parse_id: data['parse_id'], key: data['key'], description: data['description'], 
				url: data['url'], member_email: data['member_email'], permissions: data['permissions'], num_clicks: data['num_clicks'],
				rating: data['rating'], votes: data['votes'], tags: data['tags'], updatedAt: data['updated_at'])
		end
		return golinks
	end

	def self.tag_search(search_term)
		results = GoLink.search(query: {multi_match: {query: search_term, fields: ['tags'], fuzziness:0}}, :size=>100000).results
		return self.search_results_to_golinks(results)
	end

	def self.member_search(email)
		query = {
		    query: {
		        multi_match: {
		            query: email,
		            fields: ['member_email']
	            }
	        }
	    }
		results = GoLink.search(query, size: 10000).results
		golinks = Array.new
		results.each do |result|
			data =  result._source
			puts data
			golinks << ParseGoLink.new(parse_id: data['parse_id'], key: data['key'], description: data['description'], 
				url: data['url'], member_email: data['member_email'], permissions: data['permissions'], num_clicks: data['num_clicks'],
				rating: data['rating'], votes: data['votes'], tags: data['tags'], updated_at: data['updated_at'])
		end
		return golinks
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

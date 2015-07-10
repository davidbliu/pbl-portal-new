require 'set'
class GoController < ApplicationController

	def mobile
		# TODO support mobile browsing
	end
	def affix
		""" deal with key redirects if needed """
		go_key = params.keys[0]
		link_hash = go_link_hash
		go_hash = go_link_key_hash
		@current_member = current_member
		
		if params.length >= 3 and go_hash.keys.include?(go_key)
			# correctly used alias
			golink = go_hash[go_key]
			""" log tracking data for link click """
			if @current_member	
				click = ParseGoLinkClick.new
				click.member_email = @current_member.email
				click.key = golink.key
				click.time = Time.now
				click.save
			else
				click = ParseGoLinkClick.new
				click.key = golink.key
				click.time = Time.now
				click.save
			end
			# send to link url
			redirect_to golink.url
		end

		""" render the catalogue if no redirects """
		@golinks = link_hash.values
		#ParseGoLink.limit(10000).all.to_a

		""" apply filters from searching and link types"""
		@filters = Array.new

		if params.keys.include?("search_term") and params[:search_term] != "" and params[:search_term] != nil
			if params[:search_term].start_with?('http://') or params[:search_term].start_with?('https://')
				@golinks = @golinks.select{|x| x.url == params[:search_term]}
				filter = "reverse lookup:"+params[:search_term]
				@filters << filter
			else
				puts 'searching for : '+params[:search_term]
				search_result_keys = ParseGoLink.search(params[:search_term])
				puts 'search result keys were : '+search_result_keys.to_s
				@golinks = @golinks.select{|x| search_result_keys.include?(x.key)}
				filter = "search:" + params[:search_term]
				@filters << filter
			end
		end

		if params.keys.include?('link_type')
			type = params[:link_type]
			filter = "type:" + type
			@filters << filter
			@golinks = @golinks.select{|x| x.resolve_type == type}
		end

		""" get directory structure """
		@num_links = @golinks.length

		@directory_hash = ParseGoLink.directory_hash(@golinks) #.dir_hash
		@directories = @directory_hash.keys.sort
		@one_ply = ParseGoLink.one_ply(@directories)
		@directory_tree = ParseGoLink.n_ply_tree(@directories)
		@all_directories = ParseGoLink.all_directories(@golinks)
		# @subdirectories = @directory_hash.keys.select{|x| x.scan('/').length > 1}
		# puts 'these are the subdirectories '+@subdirectories.to_s
		# # @directories = @directory_hash.keys.select{|x| x.scan('/').length == 1}.sort
		# # @directories = @directory_hash.keys.map{|x| x[1..len(x)]split('/')[0]}
		# @directories = ParseGoLink.subdirectories
		# @directory_tree = get_dir_tree(@directories, @subdirectories)
		# @directories.delete('/')


		""" get favorites """
		if current_member
			# @favorite_links = Set.new(GoLinkFavorite.where(member_email: current_member.email).map{|x| x.key})
			@favorite_links = (go_link_favorite_hash.keys.include?(current_member.email) ? Set.new(go_link_favorite_hash[current_member.email]) : Array.new)
		end
		
		@resource_hub = true
	end

	def get_dir_tree(top_level, subdirectories)
		tree = Hash.new
		top_level.each do |top|
			tree[top] = ParseGoLink.subdirectories(top).select{|x| subdirectories.include?(x)}
		end
		return tree
	end

	def favorite
		key = params[:key]
		email = params[:email]
		status = params[:status]
		if email != nil and email != ""
			if status == 'favorite'
				GoLinkFavorite.destroy_all(GoLinkFavorite.where(member_email: email, key: key).to_a)
				puts 'trying to save fav'
				fav = GoLinkFavorite.new(member_email: email, key: key, time: Time.now)
				fav.save
			else
				GoLinkFavorite.destroy_all(GoLinkFavorite.where(member_email: email, key: key).to_a)
			end
		end
		invalidate_go_link_favorite_hash
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def index
		go_key = params[:key]
		link_hash = go_link_hash #see cache helper for details 
		go_hash = go_link_key_hash
		# link_hash.values.index_by(&:key) # key is key and value is link 

		if go_hash.keys.include?(go_key)
			# correctly used alias
			golink = go_hash[go_key]
			""" log tracking data for link click """
			if current_member	
				click = ParseGoLinkClick.new
				click.member_email = current_member.email
				click.key = golink.key
				click.time = Time.now
				click.save
			else
				click = ParseGoLinkClick.new
				click.key = golink.key
				click.time = Time.now
				click.save
			end
			# send to link url
			redirect_to golink.url
		else
			redirect_to '/go'
		end
		
	end
	def go(key = nil)
		"""put permissions on golinks?"""
		puts 'here are params '+params.to_s
		if key != nil
			go_key = key
		else
			go_key = params.keys[0]
		end

		link_hash = go_link_hash
		# ParseGoLink.hash
		go_hash = go_link_key_hash
		 # link_hash.values.index_by(&:key)
		
		if params.length < 3
			@message = nil
		# elsif params.keys.include?("search_term") and params[:search_term] != "" and params[:search_term] != nil
		# 	puts 'searching for : '+params[:search_term]
		# 	@search_results = ParseGoLink.search(params[:search_term]).results
		# 	@search_term = params[:search_term]
		# 	@link_hash = link_hash
		elsif go_hash.keys.include?(go_key)
			# correctly used alias
			golink = go_hash[go_key]
			""" log tracking data for link click """
			if current_member	
				click = ParseGoLinkClick.new
				click.member_email = current_member.email
				click.key = golink.key
				click.time = Time.now
				click.save
			else
				click = ParseGoLinkClick.new
				click.key = golink.key
				click.time = Time.now
				click.save
			end
			# send to link url
			redirect_to golink.url
		else
			# did not find key
			@message = 'The key ('+go_key.to_s+') was not recognized, please check the catalogue to make sure your key exists!'
		end
		# else display the catalogue
		@cwd = '/'
		if params.keys.include?('cwd')
			@cwd = params[:cwd]
		end

		""" render the directory component of the page """
		@backpaths = dir_back_paths(@cwd)
		@subdirectories = ParseGoLink.subdirectories(@cwd)
		@cwd_links = ParseGoLink.hash.values.select{|x| x.dir.start_with?(@cwd)}.sort_by{|x| [x.dir, x.key]}
		@go_key = go_key
		@key_hash = go_hash

		@filters = Array.new
		""" filter cwd links if search term exists """
		if params.keys.include?("search_term") and params[:search_term] != "" and params[:search_term] != nil
			puts 'searching for : '+params[:search_term]
			search_result_keys = ParseGoLink.search(params[:search_term])
			puts 'search result keys were : '+search_result_keys.to_s
			@cwd_links = @cwd_links.select{|x| search_result_keys.include?(x.key)}.sort_by{|x| search_result_keys.index(x.key)}
			filter = "search:" + params[:search_term]
			@filters << filter
		end

		if params.keys.include?('link_type')
			# @link_type = params[:link_type]
			type = params[:link_type]
			filter = "type:" + type
			@filters << filter
			# @filtered_type_links = ParseGoLink.hash.values.select{|x| x.resolve_type == @link_type}.sort_by{|x| x.key}
			# @type_image = ParseGoLink.type_to_image(@link_type)
			@cwd_links = @cwd_links.select{|x| x.resolve_type == type}
		end
	end

	def lookup
		url = params[:url]
		@keys = go_link_hash.values.select{|x| x.url == url}

	end
	def cwd
		@cwd = params[:cwd]
		@subdirectories = ParseGoLink.subdirectories(@cwd)
		@links = ParseGoLink.directory_links(@cwd)
		render '_cwd.html.erb', layout: false
	end

	def clearcache
		""" clear cache but also update values """
		clear_go_cache
		redirect_to '/go'
	end

	def edit
		puts 'editing : '+ params[:id].to_s
		@link = ParseGoLink.find(params[:id])
		@clicks = ParseGoLinkClick.where(key: @link.key)
	end

	def update
		""" one can edit link url or description and owner but not much else, in particular link aliases cannot be changed """
		link = go_link_hash[params[:id]]
		#ParseGoLink.find(params[:id])
		puts link
		link.url = params[:url]
		link.description = params[:description]
		# link.directory = params[:directory]
		link.directory = params[:directory] != "" ? params[:directory] : '/PBL'
		puts 'current member'
		if current_member
			puts 'current member 1'
			# link.member_id = current_member.id
			link.member_email = current_member.email
			puts 'current member 2'
		end
		link.save
		clear_go_cache
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end


	def directories
		puts 'directory params was '+params.to_s
		puts params.keys
		if params.keys.include?('dir')
			@directory = params['dir']
		else
			@directory = '/'
		end
		# @directories = @directory.split('/')
		@subdirectories = dir_back_paths(@directory)
		#.split("/")
		@dir_hash = ParseGoLink.dir_hash
		@directories = get_subdirs(@directory, @dir_hash.keys).sort
		if @dir_hash.include?(@directory)
			@links = @dir_hash[@directory].sort_by{|x| x.key}
		else
			@links = Array.new
		end

		# @directories = @dir_hash.keys.sort
	end

	""" helper methods for the directories route """
	def dir_array(directory)
		a = directory.split('/').select{|x| x!= ""}
		# a.insert(0, '/')
		return a
	end

	def dir_back_paths(directory)
		elems = dir_array(directory)
		sofar = ""
		paths = Array.new
		elems.each do |elem|
			sofar += '/' + elem
			path = Hash.new
			path['path'] = sofar
			path['string'] = elem
			paths << path
		end
		return paths
	end

	def get_subdirs(dir, all_dirs)
		all_dirs.select{|x| x.start_with?(dir)}.select{|x| x!=dir}
	end
	""" end of helpers for the directory route """

	def manage
		@message = params[:message]
		@directory = params[:directory]
		@keys = go_link_key_hash.keys

		""" directories """
		@golinks = go_link_hash.values
		@directory_hash = ParseGoLink.directory_hash(@golinks) #.dir_hash
		@directories = @directory_hash.keys.sort
		@one_ply = ParseGoLink.one_ply(@directories)
		@directory_tree = ParseGoLink.n_ply_tree(@directories)
		@all_directories = ParseGoLink.all_directories(@golinks)
		# if current_member
		# 	@my_links = ParseGoLink.limit(10000).where(member_email: current_member.email)
		# else
		# 	@my_links = Array.new
		# end
		@resource_hub = true
	end

	def reindex
		ParseGoLink.import
		# Rails.cache.write('go_link_hash', nil)
		clear_go_cache
		redirect_to '/go'
	end

	def guide

	end

	def create
		key = params[:key]
		url = params[:url]
		description = params[:description]
		directory = params[:directory] != "" ? params[:directory] : '/PBL'
		""" do some error checking """
		errors = Array.new
		if not ParseGoLink.valid_key(key)
			errors << "key"
		end
		if not ParseGoLink.valid_url(url)
			errors << "url"
		end
		if not ParseGoLink.valid_directory(directory)
			errors << "directory"
		end
		""" if there are errors, return with errors """
		if errors.length > 0
			render json: "Error with creating link", :status=>500, :content_type=>'text/html'
		else
			""" save the new link """
			golink = ParseGoLink.new(key: key, url: url, description: description, directory: directory)
			if current_member
				golink.member_email = current_member.email
			end
			golink.save
			clear_go_cache
			# render :nothing => true, :status => 200, :content_type => 'text/html'
			response.headers['Access-Control-Allow-Origin'] = '*'
			response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
			response.headers['Access-Control-Request-Method'] = '*'
			response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
			render json: "Successfully created link", :status=>200, :content_type=>'text/html'
		end
	end

	def destroy
		# Rails.cache.write('go_link_hash', nil)
		ParseGoLink.find(params[:id]).destroy
		# ParseGoLink.import #TODO should not have to reindex upon destroy
		clear_go_cache
		redirect_to '/go'
	end

	def json
		render json: GoLink.all
	end

	def metrics
		@golink = ParseGoLink.find(params[:id])
		@clicks = ParseGoLinkClick.where(key: @golink.key).sort_by{|x| x.time}.reverse
		# @member_hash = ParseMember.hash
		@resource_hub = true
	end


end
class GoController < ApplicationController
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
		Rails.cache.write('go_link_hash', nil)
		link = ParseGoLink.find(params[:id])
		puts link
		link.url = params[:url]
		link.description = params[:description]
		link.directory = params[:directory]
		puts 'current member'
		if current_member
			puts 'current member 1'
			# link.member_id = current_member.id
			link.member_email = current_member.email
			puts 'current member 2'
		end
		link.save
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
		if current_member
			@my_links = ParseGoLink.limit(10000).where(member_email: current_member.email)
		else
			@my_links = Array.new
		end
	end

	def reindex
		ParseGoLink.import
		Rails.cache.write('go_link_hash', nil)
		redirect_to '/go'
	end

	def guide

	end

	def create
		Rails.cache.write('go_link_hash', nil)
		key = params[:key]
		url = params[:url]
		description = params[:description]
		directory = params[:directory]
		if ParseGoLink.where(key: key).length > 0
			render :nothing => true, :status => 500, :content_type => 'text/html'
		else
			golink = ParseGoLink.create(key: key, url: url, description: description, directory: directory)
			if current_member
				golink.member_email = current_member.email
			end
			golink.save
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def destroy
		Rails.cache.write('go_link_hash', nil)
		ParseGoLink.find(params[:id]).destroy
		ParseGoLink.import #TODO should not have to reindex upon destroy
		redirect_to '/go'
	end

	def json
		render json: GoLink.all
	end

	def metrics
		@golink = ParseGoLink.find(params[:id])
		@clicks = ParseGoLinkClick.where(key: @golink.key).sort_by{|x| x.updated_at}
		# @member_hash = ParseMember.hash
	end


end
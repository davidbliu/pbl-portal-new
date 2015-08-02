require 'set'
require 'will_paginate/array'
class GoController < ApplicationController


	def show_collection
		name = params[:name]
		@name = name		

		@selected_tags = Array.new
		@tag_color_hash = ParseGoLinkTag.color_hash

		@collection = ParseGoLinkCollection.where(name: name).to_a[0]
		@data = JSON.parse(@collection.data)

		@golinks = cached_golinks
		@directory_hash = Hash.new
		@data['links'].each do |directory|
			directory.keys.each do |dir|
				@directory_hash[dir] = Array.new
				directory[dir].each do |link|
					key = link.split('pbl.link/')[1]
					@directory_hash[dir].concat(@golinks.select{|x| x.key == key})
					puts key 
					puts 'that was the key'
				end
			end
		end

		render 'show_collections'
	end

	def edit_collection
		@name = params[:name]
		@collection = ParseGoLinkCollection.where(name:@name).to_a[0]
		@data  = JSON.parse(@collection.data).to_yaml.strip()
	end

	def update_collection
		name = params[:name]
		yaml_data = params[:data]
		puts yaml_data

		data =  YAML.load(yaml_data)
		name = data['name']
		puts name
		existing_collections = ParseGoLinkCollection.where(name: name).to_a
		puts existing_collections
		puts 'those were existing collections'
		if existing_collections.length > 0
			existing = existing_collections[0]
			existing.data = data.to_json
			existing.save
		else
			ParseGoLinkCollection.create(data: data.to_json, name: name)
		end
		render nothing:true, status:200
		
	end

	def collections
		@collections = ParseGoLinkCollection.limit(100000).all.to_a
	end
	def tag_catalogue
		""" deal with key redirects if needed """
		# go_key = params.keys[0]
		# go_hash = go_link_key_hash

		""" render the catalogue if no redirects """

		def contains_all_tags(golink, tags)
			if not golink.tags
				return false
			end
			tags.each do |tag|
				if not golink.tags.include?(tag)
					return false
				end
			end
			return true
		end
		@selected_tags = Array.new
		page =  params[:page] ? params[:page].to_i : 1
		if params[:tags] and params[:tags] != ""
			@selected_tags = params[:tags].split(',')
			# @golinks = go_tag_hash[@selected_tags[0]]
			# @thash = go_tag_links.values
			@golinks = go_tag_links[@selected_tags[0]]
			@golinks = @golinks.select{|x| contains_all_tags(x, @selected_tags)}
		else
			# no tags, get all values from the main hash
			@golinks = cached_golinks
		end

		# get tags
		@tag_color_hash = ParseGoLinkTag.color_hash
		@tags = Set.new(@golinks.map{|x| x.tags}.select{|x| x != nil and x!= ""}.flatten()).to_a.sort  #filter through all golinks for their tags

		# paginate go links
		@golinks = @golinks.paginate(:page => page, :per_page => 100)

		# include collections
		@collections = ParseGoLinkCollection.limit(100000).all.to_a
		
		
	end


	def update_rank
		key = params[:key]
		email = params[:email]
		rating = params[:rank].to_i
		if member_email_hash.keys.include?(email) and rating <= 100
			ratings = ParseGoLinkRating.where(key:key).where(member_email: email)
			if ratings.length > 0
				puts 'editing old rating'
				r = ratings[0]
				r.rating = rating
				r.save
			else
				puts 'creating a new rating'
				ParseGoLinkRating.create(key: key, member_email: email, rating: rating)
			end
			Rails.cache.write('go_link_ratings', nil)
			render nothing: true, status: 200
		else
			render nothing:true, status:500
		end
		
	end

	def add

	end
	def mobile
		# TODO support mobile browsing
	end

	

	def admin
		# @my_links = go_link_key_hash.values.select{|x| x.member_email == current_member.email}
		# @my_uncategorized = @my_links.select{|x| x.dir == '/PBL'}
		# if current_member
		# 	@favorite_links = (go_link_favorite_hash.keys.include?(current_member.email) ? Set.new(go_link_favorite_hash[current_member.email]) : Array.new)
		# end

		@click_hash = ParseGoLinkClick.click_hash
		@recent_links = cached_golinks.sort_by{|x| x.updated_at}.reverse

	end

	def search
		@search_term = params[:search_term]
		puts 'searching for : '+params[:search_term]
		golinks = ParseGoLink.search(@search_term)
		# log this search event
		keys = golinks.select{|x| x.key}
		search_email = current_member ? current_member.email : nil
		search_event = ParseGoLinkSearch.create(member_email: search_email, search_term: @search_term, results: keys, type: 'portal', time: Time.now)
		# get search results
		# results = Array.new
		# keys.each do |key|
		# 	results << key_hash[key]
		# end

		@golinks = golinks
		@tag_color_hash = ParseGoLinkTag.color_hash
		@tags = Set.new(@golinks.map{|x| x.tags}.select{|x| x != nil and x!= ""}.flatten()).to_a.sort

		# paginate go links
		page = params[:page] ? params[:page].to_i : 1
		@golinks = @golinks.paginate(:page => page, :per_page => 100)
		@search = true
		render 'tag_catalogue'
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

		""" removed filtering by link type """
		# if params.keys.include?('link_type')
		# 	type = params[:link_type]
		# 	filter = "type:" + type
		# 	@filters << filter
		# 	@golinks = @golinks.select{|x| x.resolve_type == type}
		# end

		""" get directory structure """
		@num_links = @golinks.length

		@directory_hash = ParseGoLink.directory_hash(@golinks) #.dir_hash
		@directories = @directory_hash.keys.sort
		@one_ply = ParseGoLink.one_ply(@directories)
		@directory_tree = ParseGoLink.n_ply_tree(@directories)
		@all_directories = ParseGoLink.all_directories(@golinks)

		# move /PBL to the back
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
		golinks = ParseGoLink.where(key: go_key).to_a
		if golinks.length > 0
			# correctly used alias
			""" log tracking data for link click TODO emit tracking event from chrome extension """
			# if current_member	
			# 	click = ParseGoLinkClick.new
			# 	click.member_email = current_member.email
			# 	click.key = go_key
			# 	click.time = Time.now
			# 	click.save
			# else
			# 	click = ParseGoLinkClick.new
			# 	click.key = go_key
			# 	click.time = Time.now
			# 	click.save
			# end
			if golinks.length > 1
				@golinks = golinks
				# get tags
				@tag_color_hash = ParseGoLinkTag.color_hash
				@tags = Set.new(@golinks.map{|x| x.tags}.select{|x| x != nil and x!= ""}.flatten()).to_a.sort  #filter through all golinks for their tags
				@selected_tags = Array.new
				page = 1
				# paginate go links
				@golinks = @golinks.paginate(:page => page, :per_page => 200)

				render 'tag_catalogue'

			else
				# send to link url
				redirect_to golinks[0].url
			end
		else
			search_term = go_key
			URI.escape(search_term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
			redirect_to '/go/search?search_term='+search_term
		end
		
	end

	

	def lookup
		url = params[:url]
		@keys = cached_golinks.select{|x| x.url == url}
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
		@subdirectories = dir_back_paths(@directory)
		@dir_hash = ParseGoLink.dir_hash
		@directories = get_subdirs(@directory, @dir_hash.keys).sort
		if @dir_hash.include?(@directory)
			@links = @dir_hash[@directory].sort_by{|x| x.key}
		else
			@links = Array.new
		end
	end

	""" helper methods for the directories route """
	def dir_array(directory)
		a = directory.split('/').select{|x| x!= ""}
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
		@golinks = go_link_key_hash.values
		@directory_hash = ParseGoLink.directory_hash(@golinks) #.dir_hash
		@directories = @directory_hash.keys.sort
		@one_ply = ParseGoLink.one_ply(@directories)
		@directory_tree = ParseGoLink.n_ply_tree(@directories)
		@all_directories = ParseGoLink.all_directories(@golinks)
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

	def delete_link

		key = params[:key]

		override = (key.include?(':') and key.split(':')[-1] == 'override') ? true : false
		if override
			key = key.split(':')[0]
		end
		ParseGoLink.where(key: key).destroy_all
		# clear_go_cache
		render nothing: true, status: 200
	end

	def update_link
		key = params[:key]
		tags = params[:tags].split(',')
		description = params[:description]
		newkey = params[:newkey]

		golink = go_link_key_hash[key]
		golink.tags = tags
		golink.description = description

		if newkey and newkey != ""
			if ParseGoLink.valid_key(newkey) and not go_link_key_hash.keys.include?(newkey)
				golink.key = newkey
			end
		end
		
		golink.save
		# clear_go_cache

		@golink = golink 
		# get colors
		@tag_color_hash = ParseGoLinkTag.color_hash
		@ratings = go_link_ratings.select{|x| x.member_email == current_member.email}.index_by(&:key)
		render 'update_link',:layout =>false
		# render nothing: true, status:200
	end

	def json
		render json: GoLink.all
	end

	""" TODO move metrics to ID"""
	def metrics
		# @golink = ParseGoLink.find(params[:id])
		key = params[:key]
		@golink = ParseGoLink.where(key: key).to_a[0]
		@clicks = ParseGoLinkClick.where(key: key).sort_by{|x| x.time}.reverse

		@member_email_hash = member_email_hash
		# @current_members = current_members
		@committee_member_hash = committee_member_hash
		@resource_hub = true
		render 'metrics', :layout =>false
	end


end
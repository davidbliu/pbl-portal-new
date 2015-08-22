require 'set'
require 'will_paginate/array'
require 'timeout'
class GoController < ApplicationController

	before_filter :authorize, :except => [:index, :redirect_id, :typeahead, :ajax_search]

	def authorize
		if not current_member
			render 'authorize', layout: false
		else
			puts current_member.email
		end
	end

	def landing_page
		@url = params[:url]
		@url_matches = cached_golinks.select{|x| x.is_url_match(@url)}
	end

	def add_landing_page
		@url = params[:url] ? params[:url] : ''
		@key = params[:key] ? params[:key].downcase.gsub(' ' , '-').gsub(/[^- a-z0-9]/, '').gsub(' ','-').gsub('--', '-').gsub('--', '-') : 'example-key'
	end

	def add
		@url = params[:url]
		@key = params[:key]
		@description = params[:description]
		@permissions = params[:permissions]
		email = current_member ? current_member.email : nil
		golink = ParseGoLink.create(url:@url, key: @key, description: @description, permissions:@permissions, member_email:email)
		# reflect changes in GoLink so appears in search
		gl = GoLink.new(key: @key, description: @description, member_email: email, permissions: @permissions, url: @url)
		gl.parse_id = golink.id
		gl.save
		render json: golink, status:200
	end

	def quick_add
		@url = params[:url]
		@key = params[:key]
		@permissions = 'Anyone'
		email = current_member ? current_member.email : nil
		golink = ParseGoLink.create(url:@url, key: @key, permissions:@permissions, member_email:email)
		# reflect changes in GoLink so appears in search
		gl = GoLink.new(key: @key, member_email: email, permissions: @permissions, url: @url)
		gl.parse_id = golink.id
		gl.save
		redirect_to '/go/finished_adding?id='+golink.id
	end

	def finished_adding
		@golink = ParseGoLink.find(params[:id])

	end

	def delete
		ParseGoLink.find(params[:id]).destroy
		# reflect changes to GoLink 
		GoLink.destroy_all(parse_id: params[:id])
		render nothing:true, status:200
	end

	def edit
		golink = ParseGoLink.find(params[:id])
		golink.key = params[:key]
		golink.description = params[:description]
		golink.permissions=params[:permissions]
		golink.url = params[:url]
		# reflect changes in GoLink so appears in search
		gl = GoLink.where(parse_id:golink.id)
		if gl.length > 0
			gl = gl.first
			gl.key = params[:key]
			gl.description = params[:description]
			gl.permissions = params[:permissions]
			gl.url = params[:url]
			gl.save
		end
		golink.save
		render nothing: true, status:200
	end

	def edit_description
		golink = ParseGoLink.find(params[:id])
		golink.description = params[:description]
		# reflect changes in GoLink so appears in search
		gl = GoLink.where(parse_id:golink.id)
		if gl.length > 0
			gl = gl.first
			gl.description = params[:description]
			gl.save
		end
		golink.save
		render nothing: true, status:200
	end

	def my_recent
		@golinks = Array.new
		seen = Array.new
		clicks = ParseGoLinkClick.limit(10000000).where(member_email: current_member.email).to_a.select{|x| x.time > Time.now - 1.week}
		clicks.each do |click|
			if click.golink_id and not seen.include?(click.golink_id)
				seen << click.golink_id
			end
		end
		golinks = GoLink.find_all_by_parse_id(seen)
		# sort the golinks by their position in seeen
		go_hash = golinks.index_by(&:parse_id)
		puts go_hash.keys
		puts seen
		@golinks = seen.map{|x| go_hash[x]}.select{|x| x != nil}.map{|x| x.to_parse}.reverse
		render 'my_recent', layout:false
	end

	def popular
		# ParseGoLinkClick.limit(1000000).all.each do |click|
		@golinks = ParseGoLink.limit(10000).order('num_clicks desc').select{|x| x.can_view(current_member)}.take(20)
		render 'popular', layout:false
	end

	def typeahead
		if params[:search_term] and params[:search_term] != ''
			@search_term = params[:search_term]
		end
		render 'typeahead_homepage'
	end

	def ajax_search
		puts params[:q]
		# @golinks = cached_golinks.select{|x| x.key.include?(params[:q])}
		@golinks = ParseGoLink.search(params[:q])
		@golinks = @golinks.select{|x| x.can_view(current_member)}
		render 'ajax_search', layout: false
	end
	def dalli_client
		options = { :namespace => "app_v1", :compress => true }
    	dc = Dalli::Client.new(ENV['MEMCACHED_HOST'], options)
    	return dc 
   	end

	def my_links
		@golinks = ParseGoLink.limit(1000000).where(member_email: current_member.email).sort{|a,b| b.updated_at <=> a.updated_at}
		# apply filters
		filter = params[:filter]
		if filter and filter != ''
			if filter.include?("Shared With:")
				permissions = filter.split('Shared With:')[1].strip
				@golinks = @golinks.select{|x| x.get_permissions == permissions}
			else
				@golinks = @golinks.select{|x| (x.key and x.key.include?(filter)) or (x.description and x.description.include?(filter)) or (x.url and x.url.include?(filter))}
			end
			@filter = filter
		end
		page = params[:page] ? params[:page] : 1
		@golinks = @golinks.paginate(:page => page, :per_page => 100)
		render 'my_links'
	end

	def dashboard
		page = params[:page] ? params[:page] : 1
		sort_by = (params[:sort_by] and params[:sort_by] != 'views') ? params[:sort_by] : 'updatedAt desc'
		if params[:sort_by] == 'views'
			sort_by = 'num_clicks desc'
		end
		@golinks = ParseGoLink.order(sort_by).page(page).per(100)
		render 'dashboard'
	end


	def vote
		id = params[:id]
		type = params[:type]
		if type == 'upvote'
			ParseGoLinkRating.upvote_link(id, current_member.email)
		else
			ParseGoLinkRating.downvote_link(id, current_member.email)
		end
		golink = ParseGoLink.find(id)
		render text: golink.rating.to_s + ', ' + golink.votes.to_s + ' votes'
	end
	def index
		# TODO: accept id as input and redirect to url
		# log this click 
		go_key = params[:key].gsub('_', ' ')
		golinks = ParseGoLink.where(key: go_key).select{|x| x.can_view(current_member)}
		
		email = current_member ? current_member.email : ''
		email = params[:email] ? params[:email] : email
		# GoLog.log_click(email, go_key, Time.now)
		if golinks.length > 0
			# correctly used alias
			if golinks.length > 1
				@golinks = golinks
				page = 1
				render 'typeahead_homepage'
			else
				# send to link url
				golink = golinks[0]
				Thread.new{
					golink.log_view(current_member)
					ActiveRecord::Base.connection.close
				}
				redirect_to golink.url
			end
		else
			search_term = go_key
			URI.escape(search_term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
			redirect_to '/go?search_term='+search_term
		end
	end

	def redirect_id
		golink = ParseGoLink.find(params[:id])
		email = current_member ? current_member.email : ''
		Thread.new{
			golink.log_view(current_member)
			ActiveRecord::Base.connection.close
		}
		redirect_to golink.url
	end

	def guide
		render 'picture_guide.html.erb'
	end

	def sharing_center
		@clients = NotificationClient.limit(10000).all.select{|x| x.email != ''}
		email_lookup_hash = SecondaryEmail.email_lookup_hash
		valid_emails = SecondaryEmail.valid_emails
		@members = @clients.select{|x| valid_emails.include?(x.email)}.map{|x| email_lookup_hash[x.email]}
		@key = params[:key]

	end
	def share
		message = params[:message]
		link = params[:link]
		recipients = params[:recipients]
		recipients << current_member.email
		message = NotificationClient.push(current_member, recipients, 'PBL Link Notifier',  message, link)
		render json: message, status:200
	end


	# def permissions
	# 	@members = member_email_hash.values
	# end

	

	# def show_collection
	# 	name = params[:name]
	# 	@name = name		

	# 	@selected_tags = Array.new
	# 	@tag_color_hash = ParseGoLinkTag.color_hash

	# 	@collection = cached_golink_collections.select{|x| x.name == name}[0] #ParseGoLinkCollection.where(name: name).to_a[0]
	# 	@data = JSON.parse(@collection.data)
	# 	@description = @data.keys.include?('description') ? @data['description'] : 'no description'

	# 	# @golinks = cached_golinks
	# 	key_hash = golink_key_hash
	# 	valid_keys = Set.new(key_hash.keys)
	# 	@directory_hash = Hash.new
	# 	@data['links'].each do |directory|
	# 		directory.keys.each do |dir|
	# 			@directory_hash[dir] = Array.new
	# 			directory[dir].each do |link|
	# 				key = link.split('pbl.link/')[1]
	# 				if valid_keys.include?(key)
	# 					@directory_hash[dir].concat(key_hash[key])
	# 				end
	# 			end
	# 		end
	# 	end

	# 	render 'show_collections'
	# end

	# def edit_collection
	# 	@name = params[:name]
	# 	@collection = cached_golink_collections.select{|x| x.name == @name}[0] #ParseGoLinkCollection.where(name:@name).to_a[0]
	# 	@data  = JSON.parse(@collection.data).to_yaml.strip()
	# end

	# def update_collection
	# 	name = params[:name]
	# 	yaml_data = params[:data]
	# 	puts yaml_data

	# 	data =  YAML.load(yaml_data)
	# 	name = data['name']
	# 	puts name
	# 	existing_collections = ParseGoLinkCollection.where(name: name).to_a
	# 	puts existing_collections
	# 	puts 'those were existing collections'
	# 	if existing_collections.length > 0
	# 		existing = existing_collections[0]
	# 		existing.data = data.to_json
	# 		existing.save
	# 	else
	# 		ParseGoLinkCollection.create(data: data.to_json, name: name)
	# 	end

	# 	invalidate_cached_collections
	# 	render nothing:true, status:200
		
	# end

	# def collections
	# 	@collections = cached_golink_collections #ParseGoLinkCollection.limit(100000).all.to_a
	# end
	# def tag_catalogue
	# 	""" deal with key redirects if needed """
	# 	""" render the catalogue if no redirects """
	# 	def contains_all_tags(golink, tags)
	# 		if not golink.tags
	# 			return false
	# 		end
	# 		tags.each do |tag|
	# 			if not golink.tags.include?(tag)
	# 				return false
	# 			end
	# 		end
	# 		return true
	# 	end
	# 	@selected_tags = Array.new
	# 	page =  params[:page] ? params[:page].to_i : 1
	# 	if params[:tags] and params[:tags] != ""
	# 		@selected_tags = params[:tags].split(',')
	# 		@golinks = go_tag_links[@selected_tags[0]]
	# 		@golinks = @golinks.select{|x| contains_all_tags(x, @selected_tags)}
	# 	else
	# 		# no tags, get all values from the main hash
	# 		@golinks = cached_golinks
	# 	end
	# 	# get tags
	# 	@tag_color_hash = ParseGoLinkTag.color_hash
	# 	@tags = Set.new(@golinks.map{|x| x.tags}.select{|x| x != nil and x!= ""}.flatten()).to_a.sort  #filter through all golinks for their tags

	# 	# paginate go links
	# 	@golinks = @golinks.paginate(:page => page, :per_page => 100)

	# 	# include collections
	# 	@collections = cached_golink_collections #ParseGoLinkCollection.limit(100000).all.to_a
	# end

	# def homepage
	# 	dc = ParseCollection.dalli_client
	# 	@collections = ParseCollection.collections(dc)
	# 	parents_hash = ParseCollection.collections_parents_hash(dc)
	# 	parents = Set.new(parents_hash.keys)
	# 	@collections = @collections.select{|x| not parents.include?(x.id)}
	# 	@collections_hash = ParseCollection.collections_hash(dc)
	# end

	# def keys
	# 	start = Time.now
	# 	@golinks = cached_golinks.map{|x| 'link: ' + x.key}
	# 	end_time = Time.now
	# 	puts 'took '+ ((end_time - start) * 1000).to_s
	# 	render json: @golinks, status:200
	# end

	# def update_rank
	# 	key = params[:key]
	# 	email = params[:email]
	# 	rating = params[:rank].to_i
	# 	if member_email_hash.keys.include?(email) and rating <= 100
	# 		ratings = ParseGoLinkRating.where(key:key).where(member_email: email)
	# 		if ratings.length > 0
	# 			puts 'editing old rating'
	# 			r = ratings[0]
	# 			r.rating = rating
	# 			r.save
	# 		else
	# 			puts 'creating a new rating'
	# 			ParseGoLinkRating.create(key: key, member_email: email, rating: rating)
	# 		end
	# 		Rails.cache.write('go_link_ratings', nil)
	# 		render nothing: true, status: 200
	# 	else
	# 		render nothing:true, status:500
	# 	end
		
	# end

	

	# def admin
	# 	@click_hash = ParseGoLinkClick.click_hash
	# 	@recent_links = cached_golinks.sort_by{|x| x.updated_at}.reverse
	# end

	# def search
	# 	@search_term = params[:search_term]
	# 	puts 'searching for : '+params[:search_term]
	# 	golinks = ParseGoLink.search(@search_term)
	# 	# log this search event
	# 	Thread.new{
	# 		keys = golinks.select{|x| x.key}
	# 		search_email = current_member ? current_member.email : nil
	# 		search_event = ParseGoLinkSearch.create(member_email: search_email, search_term: @search_term, results: keys, type: 'portal', time: Time.now)
	# 	}

	# 	@golinks = golinks
	# 	@tag_color_hash = Hash.new
	# 	@tags = Set.new

	# 	# paginate go links
	# 	page = params[:page] ? params[:page].to_i : 1
	# 	@golinks = @golinks.paginate(:page => page, :per_page => 100)
	# 	# @search = true
	# 	render 'search'
	# end

	# def favorite
	# 	key = params[:key]
	# 	email = params[:email]
	# 	status = params[:status]
	# 	if email != nil and email != ""
	# 		if status == 'favorite'
	# 			GoLinkFavorite.destroy_all(GoLinkFavorite.where(member_email: email, key: key).to_a)
	# 			puts 'trying to save fav'
	# 			fav = GoLinkFavorite.new(member_email: email, key: key, time: Time.now)
	# 			fav.save
	# 		else
	# 			GoLinkFavorite.destroy_all(GoLinkFavorite.where(member_email: email, key: key).to_a)
	# 		end
	# 	end
	# 	invalidate_go_link_favorite_hash
	# 	render :nothing => true, :status => 200, :content_type => 'text/html'
	# end


	

	# def lookup
	# 	url = params[:url]
	# 	@keys = cached_golinks.select{|x| x.url == url}
	# end
	
	# def cwd
	# 	@cwd = params[:cwd]
	# 	@subdirectories = ParseGoLink.subdirectories(@cwd)
	# 	@links = ParseGoLink.directory_links(@cwd)
	# 	render '_cwd.html.erb', layout: false
	# end

	# def clearcache
	# 	""" clear cache but also update values """
	# 	clear_go_cache
	# 	redirect_to '/go'
	# end

	# def edit
	# 	puts 'editing : '+ params[:id].to_s
	# 	@link = ParseGoLink.find(params[:id])
	# 	@clicks = ParseGoLinkClick.where(key: @link.key)
	# end

	# def update
	# 	""" one can edit link url or description and owner but not much else, in particular link aliases cannot be changed """
	# 	link = go_link_hash[params[:id]]
	# 	#ParseGoLink.find(params[:id])
	# 	puts link
	# 	link.url = params[:url]
	# 	link.description = params[:description]
	# 	# link.directory = params[:directory]
	# 	link.directory = params[:directory] != "" ? params[:directory] : '/PBL'
	# 	puts 'current member'
	# 	if current_member
	# 		puts 'current member 1'
	# 		# link.member_id = current_member.id
	# 		link.member_email = current_member.email
	# 		puts 'current member 2'
	# 	end
	# 	link.save
	# 	clear_go_cache

	# 	render :nothing => true, :status => 200, :content_type => 'text/html'
	# end


	# def directories
	# 	puts 'directory params was '+params.to_s
	# 	puts params.keys
	# 	if params.keys.include?('dir')
	# 		@directory = params['dir']
	# 	else
	# 		@directory = '/'
	# 	end
	# 	@subdirectories = dir_back_paths(@directory)
	# 	@dir_hash = ParseGoLink.dir_hash
	# 	@directories = get_subdirs(@directory, @dir_hash.keys).sort
	# 	if @dir_hash.include?(@directory)
	# 		@links = @dir_hash[@directory].sort_by{|x| x.key}
	# 	else
	# 		@links = Array.new
	# 	end
	# end

	# """ helper methods for the directories route """
	# def dir_array(directory)
	# 	a = directory.split('/').select{|x| x!= ""}
	# 	return a
	# end

	# def dir_back_paths(directory)
	# 	elems = dir_array(directory)
	# 	sofar = ""
	# 	paths = Array.new
	# 	elems.each do |elem|
	# 		sofar += '/' + elem
	# 		path = Hash.new
	# 		path['path'] = sofar
	# 		path['string'] = elem
	# 		paths << path
	# 	end
	# 	return paths
	# end

	# def get_subdirs(dir, all_dirs)
	# 	all_dirs.select{|x| x.start_with?(dir)}.select{|x| x!=dir}
	# end
	# """ end of helpers for the directory route """

	# def manage
	# 	@message = params[:message]
	# 	@directory = params[:directory]
	# 	@keys = go_link_key_hash.keys

	# 	""" directories """
	# 	@golinks = go_link_key_hash.values
	# 	@directory_hash = ParseGoLink.directory_hash(@golinks) #.dir_hash
	# 	@directories = @directory_hash.keys.sort
	# 	@one_ply = ParseGoLink.one_ply(@directories)
	# 	@directory_tree = ParseGoLink.n_ply_tree(@directories)
	# 	@all_directories = ParseGoLink.all_directories(@golinks)
	# 	@resource_hub = true
	# end

	# def reindex
	# 	ParseGoLink.import
	# 	# Rails.cache.write('go_link_hash', nil)
	# 	clear_go_cache
	# 	redirect_to '/go'
	# end

	

	# def create
	# 	key = params[:key]
	# 	url = params[:url]
	# 	description = params[:description]
	# 	directory = params[:directory] != "" ? params[:directory] : '/PBL'
	# 	""" do some error checking """
	# 	errors = Array.new
	# 	if not ParseGoLink.valid_key(key)
	# 		errors << "key"
	# 	end
	# 	if not ParseGoLink.valid_url(url)
	# 		errors << "url"
	# 	end
	# 	if not ParseGoLink.valid_directory(directory)
	# 		errors << "directory"
	# 	end
	# 	""" if there are errors, return with errors """
	# 	if errors.length > 0
	# 		render json: "Error with creating link", :status=>500, :content_type=>'text/html'
	# 	else
	# 		""" save the new link """
	# 		golink = ParseGoLink.new(key: key, url: url, description: description, directory: directory)
	# 		if current_member
	# 			golink.member_email = current_member.email
	# 		end
	# 		golink.save
	# 		clear_go_cache
	# 		# render :nothing => true, :status => 200, :content_type => 'text/html'
	# 		response.headers['Access-Control-Allow-Origin'] = '*'
	# 		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
	# 		response.headers['Access-Control-Request-Method'] = '*'
	# 		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
	# 		render json: "Successfully created link", :status=>200, :content_type=>'text/html'
	# 	end
	# end

	# def destroy
	# 	# Rails.cache.write('go_link_hash', nil)
	# 	ParseGoLink.find(params[:id]).destroy
	# 	# ParseGoLink.import #TODO should not have to reindex upon destroy
	# 	clear_go_cache
	# 	redirect_to '/go'
	# end

	# def delete_link

	# 	key = params[:key]

	# 	override = (key.include?(':') and key.split(':')[-1] == 'override') ? true : false
	# 	if override
	# 		key = key.split(':')[0]
	# 	end
	# 	ParseGoLink.where(key: key).destroy_all
	# 	# clear_go_cache
	# 	render nothing: true, status: 200
	# end

	# def update_link
	# 	key = params[:key]
	# 	tags = params[:tags].split(',')
	# 	description = params[:description]
	# 	newkey = params[:newkey]

	# 	golink = go_link_key_hash[key]
	# 	golink.tags = tags
	# 	golink.description = description

	# 	if newkey and newkey != ""
	# 		if ParseGoLink.valid_key(newkey) and not go_link_key_hash.keys.include?(newkey)
	# 			golink.key = newkey
	# 		end
	# 	end
		
	# 	golink.save
	# 	# clear_go_cache

	# 	@golink = golink 
	# 	# get colors
	# 	@tag_color_hash = ParseGoLinkTag.color_hash
	# 	@ratings = go_link_ratings.select{|x| x.member_email == current_member.email}.index_by(&:key)
	# 	render 'update_link',:layout =>false
	# 	# render nothing: true, status:200
	# end


	# """ TODO move metrics to ID"""
	# def metrics
	# 	# @golink = ParseGoLink.find(params[:id])
	# 	key = params[:key]
	# 	@golink = ParseGoLink.where(key: key).to_a[0]
	# 	@clicks = ParseGoLinkClick.where(key: key).sort_by{|x| x.time}.reverse

	# 	@member_email_hash = member_email_hash
	# 	# @current_members = current_members
	# 	@committee_member_hash = committee_member_hash
	# 	@resource_hub = true
	# 	render 'metrics', :layout =>false
	# end


end
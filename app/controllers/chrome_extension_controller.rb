class ChromeExtensionController < ApplicationController
	def create_go_link

		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

		key = params[:key]
		url = params[:url]
		description = params[:description]
		directory = params[:directory] != "" ? params[:directory] : '/PBL'
		override = (key.include?(':') and key.split(':')[-1] == 'override') ? true : false
		if override
			key = key.split(':')[0]
		end

		puts 'override is '+override.to_s
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
		if go_link_key_hash.keys.include?(key)
			if not override
				old_link = go_link_key_hash[key]
				msg = "<h3>Key "+key+" already exists</h3>"
				msg += "<ul class = 'list-group'><li class = 'list-group-item'><b>Description: </b>"+old_link.description + "</li>"
				msg += "<li class = 'list-group-item'><b>URL: </b>"+old_link.url + "</li>"
				msg += "<li class = 'list-group-item'><b>Directory: </b>"+old_link.dir + "</li></ul>"
				msg += "<h4 style = 'color:blue'>To override a key, submit as key as \"key:override\"</h4>"
				render json: msg, :status=>200, :content_type=>'text/html'
			elsif errors.length == 0
				golink = go_link_key_hash[key]
				golink.url = url 
				golink.directory = directory
				golink.description = description
				golink.save
				clear_go_cache
				render json: "<h3>"+key+" was successfully overridden</h3><button class = 'btn btn-danger' id = 'undo-btn'>Remove</button>", :status=> 200
			else
				render json: "<h3>Errors: " + errors.to_s + "</h3>", :status => 200
			end
		elsif errors.length > 0
			render json: "<h3>Errors creating link: "+errors.to_s+" </h3>", :status=>500, :content_type=>'text/html'
		else
			""" save the new link """
			golink = ParseGoLink.new(key: key, url: url, description: description, directory: directory)
			if current_member
				golink.member_email = current_member.email
			end
			golink.save
			clear_go_cache
			render json: "<h3>Successfully created link</h3><ul class = 'list-group'><li class = 'list-group-item'>pbl.link/"+golink.key+"</li></ul><button class = 'btn btn-danger' id = 'undo-btn'>Undo</button>", :status=>200, :content_type=>'text/html'
		end
	end

	def undo_create
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

		key = params[:key]

		override = (key.include?(':') and key.split(':')[-1] == 'override') ? true : false
		if override
			key = key.split(':')[0]
		end

		go_link_key_hash[key].destroy
		clear_go_cache
		render json: "<h3>"+key+" has been removed</h3>", :status => 200
	end

	def lookup_url
		url = params[:url]
		matches = go_link_hash.values.select{|x| x.is_url_match(url)}
		match_string = "<ul class = 'list-group'>"
		matches.each do |match|
			match_string += "<li class = 'list-group-item'>pbl.link/" + match.key + "</li>"
		end
		match_string += "</ul>"

		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
		if matches.length == 0 
			render json: "<h4>This URL is not in PBL Links yet</h4>"+match_string, :status=>200, :content_type=>'text/html'
		else
			render json: match_string, :status=>200, :content_type=>'text/html'
		end
	end


	def create_directory
		directory = params[:directory] 
		if ParseGoLink.create_directory(directory)
			clear_go_cache
			response.headers['Access-Control-Allow-Origin'] = '*'
			response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
			response.headers['Access-Control-Request-Method'] = '*'
			response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
			render json: "<h3>Successfully created " + directory + "</h3>", :status=>200, :content_type=>'text/html'
		else
			render json: "Error creating directory", :status=>500, :content_type=>'text/html'
		end
	end

	def directories_dropdown
		@golinks = go_link_hash.values
		@directory_hash = ParseGoLink.directory_hash(@golinks) #.dir_hash
		@directories = @directory_hash.keys.sort
		@one_ply = ParseGoLink.one_ply(@directories)
		@directory_tree = ParseGoLink.n_ply_tree(@directories)
		@all_directories = ParseGoLink.all_directories(@golinks)
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
		render 'directories_dropdown', layout: false
	end

	def search
		search_term = params[:search_term]
		# @golinks = go_link_hash.values
		# # filter by search term
		# results = Array.new
		# @golinks.each do |golink|
		# 	if golink.key.include?(search_term) or golink.url.include?(search_term) or golink.description.include?(search_term)
		# 		results << golink
		# 	else
		# 		golink.key.split('-').each do |term|
		# 			if term.include?(search_term)
		# 				results << golink
		# 			end
		# 		end
		# 	end
		# end
		key_hash = go_link_key_hash
		keys = ParseGoLink.search(search_term)
		results = Array.new
		keys.each do |key|
			results << key_hash[key]
		end
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
		render json: results, :status=>200
	end
end
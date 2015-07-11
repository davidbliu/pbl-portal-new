class ChromeExtensionController < ApplicationController
	def create_go_link
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
			render json: "<h3>Successfully created link</h3><p><h3>View your link at pbl.link/"+golink.key+"</h3></p>", :status=>200, :content_type=>'text/html'
		end
	end

	def lookup_url
		matches = go_link_hash.values.select{|x| x.url == params[:url]}
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
		@golinks = go_link_hash.values
		# filter by search term
		results = Array.new
		@golinks.each do |golink|
			if golink.key.include?(search_term) or golink.url.include?(search_term) or golink.description.include?(search_term)
				results << golink
			else
				golink.key.split('-').each do |term|
					if term.include?(search_term)
						results << golink
					end
				end
			end
		end
		response.headers['Access-Control-Allow-Origin'] = '*'
		response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		response.headers['Access-Control-Request-Method'] = '*'
		response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
		render json: results, :status=>200
	end
end
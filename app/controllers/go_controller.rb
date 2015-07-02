class GoController < ApplicationController
	def go
		"""put permissions on golinks?"""
		puts 'here are params '+params.to_s
		link_hash = ParseGoLink.hash
		go_hash = link_hash.values.index_by(&:key)
		@num_links = go_hash.keys.length
		go_key = params.keys[0]
		if params.length < 3
			@message = nil
		elsif params.keys.include?("search_term") and params[:search_term] != "" and params[:search_term] != nil
			puts 'searching for : '+params[:search_term]
			@search_results = ParseGoLink.search(params[:search_term]).results
			@search_term = params[:search_term]
			@link_hash = link_hash
		elsif go_hash.keys.include?(go_key)
			# correctly used alias
			golink = go_hash[go_key]
			""" log tracking data for link click """
			if current_member	
				click = ParseGoLinkClick.new()
				click.member_id = current_member.id
				click.key = golink.key
				click.time = Time.now
				click.save
			else
				click = ParseGoLinkClick.new()
				click.member_id = -1
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
		@go_key = go_key
		@key_hash = go_hash
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
		puts 'current member'
		if current_member
			puts 'current member 1'
			link.member_id = current_member.id
			puts 'current member 2'
		end
		link.save
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def catalogue
		option = params[:option]
		# @member_hash = Member.member_hash
		@member_hash = ParseMember.hash

		if option == 'resource-type'
			@partitioned_catalogue = ParseGoLink.catalogue_by_resource_type
			render '_catalogue_partitioned.html.erb', layout: false
		elsif option == 'trending'
			@go_links = ParseGoLink.hash.values.sort_by{|x| x.updated_at}.reverse[0..9]
			render '_catalogue.html.erb', layout: false
		elsif option == 'member_links'
			puts 'params were : '+params.to_s
			member_id = params[:member_id] #TODO migrate current_member so uses the right id
			@go_links = ParseGoLink.where(member_id: member_id).sort_by{|x| x.key}
			render '_catalogue.html.erb', layout: false
		elsif option == 'prefix-suffix'
			@partitioned_catalogue = ParseGoLink.catalogue_by_fix
			render '_catalogue_partitioned.html.erb', layout: false
		else
			@go_links = ParseGoLink.all.sort_by{|link| link.key}
			render '_catalogue.html.erb', layout: false
		end
	end

	def directories
		@dir_hash = ParseGoLink.dir_hash
		@directories = @dir_hash.keys.sort
	end

	def manage
	end

	def member_links
		member_id = params[:id]
		@member_links = ParseGoLink.where(member_id: member_id).sort_by{|x| x.key}
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
		if ParseGoLink.where(key: key).length > 0
			render :nothing => true, :status => 500, :content_type => 'text/html'
		else
			golink = ParseGoLink.create(key: key, url: url, description: description)
			if current_member
				golink.member_id = current_member.id
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


end
class GoController < ApplicationController
	def go
		# if not current_member
		# 	redirect_to :controller=> 'members', :action=>'no_permission'
		# end
		# go_hash = GoLink.go_link_hash
		puts 'here are params '+params.to_s
		go_hash = ParseGoLink.key_hash
		go_key = params.keys[0]
		if params.length < 3
			@message = nil
		elsif params.keys.include?("search_term")
			puts 'searching for : '+params[:search_term]
			@search_results = ParseGoLink.search(params[:search_term]).results
		elsif go_hash.keys.include?(go_key)
			golink = go_hash[go_key]
			# log click tracking data
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
			@message = 'The key ('+go_key.to_s+') was not recognized, please check the catalogue to make sure your key exists!'
		end
		# else display the catalogue
		@go_key = go_key
	end

	def catalogue
		option = params[:option]
		@member_hash = Member.member_hash
		@go_link_id_hash = ParseGoLink.hash
		if option == 'resource-type'
			@partitioned_catalogue = ParseGoLink.catalogue_by_resource_type
			render '_catalogue_partitioned.html.erb', layout: false
		elsif option == 'trending'
			@go_links = ParseGoLink.all[0..9]
			render '_catalogue.html.erb', layout: false

		elsif option == 'prefix-suffix'
			@partitioned_catalogue = ParseGoLink.catalogue_by_fix
			render '_catalogue_partitioned.html.erb', layout: false
		elsif option == 'metrics'
			redirect_to 'http://'+ENV['HOST'] +'/go/clicks', layout: false
		else
			@go_links = ParseGoLink.all.sort_by{|link| link.key}
			render '_catalogue.html.erb', layout: false
		end
	end

	def manage
		@go_links = GoLink.all.order(:key)
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
		GoLink.find(params[:id]).destroy!
		Rails.cache.write('go_link_hash', nil)
		redirect_to :back
	end

	def json
		render json: GoLink.all
	end


end
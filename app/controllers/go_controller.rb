class GoController < ApplicationController
	def go
		# if not current_member
		# 	redirect_to :controller=> 'members', :action=>'no_permission'
		# end
		go_hash = GoLink.go_link_hash
		go_key = params.keys[0]
		if params.length < 3
			@message = nil
		elsif go_hash.keys.include?(go_key)
			golink = go_hash[go_key]
			# log click tracking data
			if current_member	
				click = GoLinkClick.new()
				click.member_id = current_member.id
				click.go_link_id = golink.id
				click.go_link_key = golink.key
				click.save!
			else
				click = GoLinkClick.new()
				click.member_id = -1
				click.go_link_id = golink.id
				click.go_link_key = golink.key
				click.save!
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
		@go_link_id_hash = GoLink.go_link_id_hash
		if option == 'resource-type'
			@partitioned_catalogue = GoLink.catalogue_by_resource_type
			# render json: 'resource-type', :status=> 200
			render '_catalogue_partitioned.html.erb', layout: false
		elsif option == 'prefix-suffix'
			@partitioned_catalogue = GoLink.catalogue_by_fix
			render '_catalogue_partitioned.html.erb', layout: false
		elsif option == 'metrics'
			redirect_to 'http://'+ENV['HOST'] +'/go/clicks', layout: false
		else
			@go_links = GoLink.all.order(:key)
			@member_hash = Member.member_hash
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
		if GoLink.where(key: key).length > 0
			render :nothing => true, :status => 500, :content_type => 'text/html'
		else
			golink = GoLink.create(key: key, url: url, description: description)
			if current_member
				golink.member_id = current_member.id
			end
			golink.save!
		end
			# redirect_to '/go/manage'
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
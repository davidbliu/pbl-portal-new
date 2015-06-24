class GoController < ApplicationController
	def go
		go_hash = go_link_hash
		go_key = params.keys()[0]
		if go_key == nil
			@message = 'No go key was provided'
		elsif go_hash.keys.include?(go_key)
			redirect_to go_hash[go_key].url
		else
			@message = 'The go key ('+go_key.to_s+') was not recognized, please check the catalogue to make sure your key exists!'
		end
		# else display the catalogue
		@go_key = go_key
		@go_links = GoLink.all.order(:key)
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
			golink.save!
		end
			# redirect_to '/go/manage'
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def destroy
		GoLink.find(params[:id]).destroy!
		Rails.cache.write('go_link_hash', nil)
		redirect_to '/go/manage'
	end

	def go_link_hash
		go_hash = Rails.cache.read('go_link_hash')
		if go_hash != nil
			return go_hash
		end

		go_hash = Hash.new
		GoLink.all.each do |golink|
			go_hash[golink.key] = golink
		end
		Rails.cache.write('go_link_hash', go_hash)
		return go_hash
	end


end
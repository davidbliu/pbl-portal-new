class CollectionsController < ApplicationController

	def index
		dc = ParseCollection.dalli_client
		@collections = ParseCollection.collections(dc)
		childs = Set.new(ParseCollection.collections_parents_hash(dc).keys)
		@collections = @collections.select{|x| not childs.include?(x.id)}
		@collection_hash = ParseCollection.collections_hash(dc)
	end

	def collection_names
		
		render json: ParseCollection.collections.map{|x| x.name}, status:200
	end

	def cache_collections
		ParseCollection.cache_collections
		redirect_to '/go'
	end

	def view_collection
		id = params[:id]
		dc = ParseCollection.dalli_client
		@collection_hash = ParseCollection.collections_hash(dc)
		@collection = @collection_hash["80t3MeZmiQ"]
		if @collection_hash.keys.include?(id)
			@collection = @collection_hash[id]
		end
		

		
		golinks = cached_golinks
		@collection_golinks = ParseCollection.collection_golinks(dc)
		@golinks = @collection.get_golinks(golinks)

		parents_hash = ParseCollection.collections_parents_hash(dc)
		if parents_hash.keys.include?(@collection.id)
			puts 'this colllection has a parent'
			@parents = parents_hash[@collection.id].map{|x| @collection_hash[x]}
		end

	end
end
require 'timeout'

class ParseCollection < ParseResource::Base
	fields :name, :golinks, :subcollections, :description, :groups, :data

	def get_golinks(cached_golinks)
		ids = Set.new(self.golinks)
		cached_golinks.select{|x| ids.include?(x.id)}
	end

	def self.import
		golinks = ParseGoLink.limit(13).all.to_a.map{|x| x.id}
		wd_collection = ParseCollection.create(golinks:golinks, name: "WD Articles 2015", subcollections:[])
	end

	def self.dalli_client
		options = { :namespace => "app_v1", :compress => true }
    	dc = Dalli::Client.new(ENV['MEMCACHED_HOST'], options)
    	return dc
	end

	def self.collections(dc = self.dalli_client)
		dc.get('collections')
	end

	def self.collections_hash(dc = self.dalli_client)
		dc.get('collections_hash')
	end

	def self.collections_parents_hash(dc = self.dalli_client)
		dc.get('collections_parents_hash')
	end

	def self.collection_golinks(dc = self.dalli_client)
		dc.get('collection_golinks')
	end
	def self.cache_collections
		puts 'caching collections'
		Thread.new{
			status = Timeout::timeout(30) {
				puts 'thread has spawned'
				dc = dalli_client
				collections = ParseCollection.limit(10000000).to_a
				collections_parents_hash = Hash.new
				puts 'constructing parents hash'
				collections.each do |collection|
					if collection.subcollections
						collection.subcollections.each do |id|
							if not collections_parents_hash.keys.include?(id)
								collections_parents_hash[id] = Array.new
							end
							collections_parents_hash[id] << collection.id
						end
					end
				end
				puts 'constructing collection_golinks'
				golinks = ParseGoLink.cached_golinks
				collection_golinks = Hash.new
				collections.each do |collection|
					collection_golinks[collection.id] = collection.get_golinks(golinks)
				end
				dc.set('collection_golinks', collection_golinks)
				dc.set('collections', collections)
				dc.set('collections_hash', collections.index_by(&:id))
				dc.set('collections_parents_hash', collections_parents_hash)
				puts 'finished'
			}
		}
		puts 'returning'
		return true
	end
end
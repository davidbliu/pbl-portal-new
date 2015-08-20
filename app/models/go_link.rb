require 'elasticsearch/model'
class GoLink < ActiveRecord::Base
	attr_accessible :key, :url, :description, :permissions, :member_email
	include Elasticsearch::Model
	include Elasticsearch::Model::Callbacks

	GoLink.__elasticsearch__.client = Elasticsearch::Client.new host: ENV['ELASTICSEARCH_HOST']

	def to_parse
		ParseGoLink.new(parse_id: self.parse_id, key: self.key, description: self.description, member_email: self.member_email,
			permissions: self.permissions, url: self.url)
	end
  """ elasticsearch """

	def short_url
		if url.length > 50
			return url.first(50) + "..."
		else
			return url
		end
	end
	def self.go_link_hash
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

	def self.go_link_id_hash
		return GoLink.all.index_by(&:id)
	end


	def self.catalogue_by_resource_type
		types = Array.new
		types_keyword = Array.new

		types << 'Google Drive'
		types_keyword << 'drive.google.com'

		types << 'Google Docs'
		types_keyword << 'docs.google.com'

		types << 'Piazza'
		types_keyword << 'piazza.com'

		types << 'PBL Portal'
		types_keyword << '.berkeley-pbl.com'

		types << 'Google Forms'
		types_keyword << '/viewform'

		# types << 'other'
		# types_keyword << ''
		# set up result hash
		result = Hash.new
		types.each do |type|
			result[type] = Array.new
		end
		result['other'] = Array.new
		# populate result hash with list of links for each type
		link_hash = self.go_link_id_hash
		link_hash.keys.each do |id|
			url = link_hash[id].url
			matches = 0
			types.each_with_index do |type, index|
				if url.include?(types_keyword[index])
					result[type] << id
					matches = matches + 1
				end
			end
			if matches == 0
				result['other'] << id
			end
		end
		# remove empty partitions
		empty_partitions = Array.new
		result.keys.each do |partition|
			if result[partition].length < 1
				empty_partitions << partition
			end
		end
		empty_partitions.each do |partition|
			result.delete(partition)
		end
		return result
	end

	def self.catalogue_by_fix
		result = Hash.new
		link_hash = self.go_link_id_hash
		link_hash.keys.each do |id|
			key = link_hash[id].key
			chunks = key.split('-')
			chunks.each do |chunk|
				if not result.keys.include?(chunk)
					result[chunk] = Array.new
				end
				result[chunk] << id
			end
		end
		puts 'this is the resul'
		puts result
		return result
	end
end

require 'elasticsearch/model'

class PgPost < ActiveRecord::Base
	attr_accessible :title, :content, :author, :view_permissions, :edit_permissions, :parse_id, :tags
	serialize :tags
	include Elasticsearch::Model
	include Elasticsearch::Model::Callbacks
	PgPost.__elasticsearch__.client = Elasticsearch::Client.new host: ENV['ELASTICSEARCH_HOST']

	def to_parse
		return BlogPost.new(title:self.title, content:self.content, view_permissions:self.view_permissions, edit_permissions:self.edit_permissions,
			author:self.author, id: self.parse_id, timestamp: self.timestamp, parse_id: self.parse_id, post_type: self.post_type,
			tags: self.tags)
	end

	def get_parse_id
		return self.parse_id
	end

end

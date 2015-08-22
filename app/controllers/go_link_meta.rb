require 'timeout'
class GoLinkMeta < ParseResource::Base
	fields :name, :array_data, :string_data

	def self.save_tags
		tags = ['wd', 'ht', 'neon', 'parse', 'web development', 'parse', 'articles', 'pd', 'ex', 'fall 2014', 'fall 2015', 'spring 2015']
		GoLinkMeta.create(name: 'tags', array_data: tags)
	end

	def self.tags
		return GoLinkMeta.where(name:'tags').to_a[0].array_data
	end
end
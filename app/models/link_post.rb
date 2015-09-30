class LinkPost < ParseResource::Base
	fields :title, :content, :tag

	def to_json
		return {'title'=> self.title, 'content'=> self.content, 'tag'=> self.tag, 'id'=>self.id}
	end
	def self.save_post(title, content, tag)
		post = LinkPost.where(title: title).where(tag: tag).to_a
		if post.length == 0
			post = LinkPost.new
		else
			post = post[0]
		end
		post.title = title
		post.tag = tag
		post.content = content
		post.save
	end
	def self.page_posts(tag)
		if not tag.include?('#')
			tag = '#' + tag
		end
		return LinkPost.where(tag: tag).to_a
	end
end

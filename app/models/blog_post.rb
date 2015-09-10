class BlogPost < ParseResource::Base
	fields :title, :content, :author, :view_permissions, 
	:edit_permissions, :timestamp, :parse_id, :post_type, :tags, :last_editor

	def is_admin(member)
		admin_emails = ['davidbliu@gmail.com','akwan726@gmail.com', 'nathalie.nguyen@berkeley.edu']
		if member and admin_emails.include?(member.email)
			return true
		end
		return false
	end

	def get_title
		self.title and self.title != '' ? self.title : 'no title'
	end

	def get_tags
		self.tags ? self.tags : ['Other']
	end

	def get_post_type
		(self.post_type and self.post_type != '') ? self.post_type : 'Other'
	end

	def self.tags 
		return ['Other', 'Announcements', 'Events', 'Reminders', 'CO', 'CS', 'FI', 'HT', 'IN', 'PB', 'SO', 'WD', 'EX', 'PD', 'MK', "Email", "Tech"]
	end

	def self.permissions
		return ['Only Me', 'Only Execs', 'Only Officers', 'Only PBL', 'Anyone']
	end

	def self.types 
		return ['Other', 'CO', 'CS', 'FI', 'HT', 'IN', 'PB', 'SO', 'WD', 'EX', 'PD', 'MK', "Email"]
	end

	def get_parse_id
		return self.parse_id ? self.parse_id : self.id
	end

	def self.save_post(id, title, content, editor, post_type, view_permissions='Anyone', edit_permissions='Anyone', tags = [])
		if not id
			post = BlogPost.new
			post.author = editor
		else
			post = BlogPost.find(id)
		end
		post.title = title
		post.content = content 
		post.last_editor = editor
		post.timestamp = Time.now
		post.view_permissions = view_permissions
		post.edit_permissions = edit_permissions
		post.timestamp = Time.now
		post.post_type = post_type
		post.tags = tags
		post.save

		pg_post = PgPost.where(parse_id: post.get_parse_id)
		pg_post.destroy_all
		# save a postgres version
		pg_post = PgPost.new
		pg_post.parse_id = post.get_parse_id
		pg_post.title = post.title
		pg_post.content = post.content
		pg_post.author = post.author
		pg_post.last_editor = post.last_editor
		pg_post.view_permissions = post.view_permissions
		pg_post.edit_permissions = post.edit_permissions
		pg_post.timestamp = post.timestamp
		pg_post.post_type = post.post_type
		pg_post.tags = post.tags
		pg_post.save
		# reindex to search 
		PgPost.import

	end

	def get_view_permissions
		p = (self.view_permissions and self.view_permissions != '')  ? self.view_permissions : 'Anyone'
		return p.strip
	end

	def get_edit_permissions
		p =  (self.edit_permissions and self.edit_permissions != '')  ? self.edit_permissions : 'Anyone'
		return p.strip
	end

	def can_edit(member)
		if member.email == self.author or member.email == self.last_editor
			return true
		end
		return has_permissions(member, self.get_edit_permissions)
	end

	# true for links that only have 1 tag : "WD"
	def is_wd
		if self.tags and self.tags.length == 1 and self.tags[0]== 'WD'
			return true
		end
	end
	def can_view(member)
		if member.email == self.author or member.email == self.last_editor
			return true
		end
		# only show wd links to wd cms unless they have more than 1 tag
		if self.is_wd and member.committee != "WD"
			return false
		end
		return has_permissions(member, self.get_view_permissions)
	end


	def has_permissions(member, permissions)
		if is_admin(member)
			return true
		end
		permissions = permissions.strip
		if member == nil
			return permissions == 'Anyone'
		end
		if permissions == 'Anyone'
			return true
		end

		if permissions == 'Only PBL'
			return (member and member.email != nil and member.email != '')
		end

		if permissions == 'Only Officers'
			return (member and member.position != nil and (member.position == 'chair' or member.position == 'exec'))
		end

		if permissions == 'Only Execs'
			return (member and member.position != nil and member.position == 'exec')
		end

		if permissions == 'Only My Committee'
			return true
		end
	end

	def self.search(search_term)
		results = PgPost.search(search_term).results
		# results = PgPost.search(query: {multi_match: {query: search_term, fields: ['title^3', 'author^2', 'content','tags'], fuzziness:1}}, :size=>100).results
		return self.results_to_parse_posts(results)
	end

	def self.from_pg_posts(pg_posts)
		return pg_posts.map{|x| x.to_parse}
	end

	def self.results_to_parse_posts(results)
		posts = []
		ids = []
		results.each do |result|
			data =  result._source
			ids << data['id']
		end
		posts = PgPost.find_all_by_id(ids).map{|x| x.to_parse}
		return posts
	end
	def self.import
		PgPost.destroy_all
		all_posts = BlogPost.limit(100000).all.to_a
		all_posts.each do |post|
			pg_post = PgPost.new
			pg_post.parse_id = post.id
			pg_post.title = post.title
			pg_post.author = post.author
			pg_post.edit_permissions = post.edit_permissions
			pg_post.view_permissions = post.view_permissions
			pg_post.content = post.content
			pg_post.timestamp = post.timestamp
			pg_post.tags = post.tags
			pg_post.last_editor = post.last_editor
			pg_post.created_at = post.created_at
			pg_post.save
			puts pg_post.author
		end
		PgPost.import
	end
end

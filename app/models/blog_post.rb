class BlogPost < ParseResource::Base
	fields :title, :content, :author, :permissions, :edit_permissions

	def self.save_post(id, title, content, author, permissions='Anyone', edit_permissions='Anyone')
		if not id
			BlogPost.create(title:title, content:content, author:author, permissions: permissions, edit_permissions: edit_permissions)
		else
			post = BlogPost.find(id)
			post.title = title
			post.content = content 
			post.author = author
			post.permissions = permissions
			post.edit_permissions = edit_permissions
			post.save
		end
	end

	def can_edit(email)
		if email == self.author
			return true
		end
		officer_emails = ['davidbliu@gmail.com']
		if officer_emails.include?(email)
			return true
		end
	end
end

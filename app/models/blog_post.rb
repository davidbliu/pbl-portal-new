class BlogPost < ParseResource::Base
	fields :title, :content, :author, :view_permissions, :edit_permissions

	def self.save_post(id, title, content, author, view_permissions='Anyone', edit_permissions='Anyone')
		if not id
			BlogPost.create(title:title, content:content, author:author, view_permissions: permissions, edit_permissions: edit_permissions)
		else
			post = BlogPost.find(id)
			post.title = title
			post.content = content 
			post.author = author
			post.view_permissions = view_permissions
			post.edit_permissions = edit_permissions
			post.save
		end
	end

	def get_view_permissions
		return (self.view_permissions and self.view_permissions != '')  ? self.view_permissions : 'Anyone'
	end

	def get_edit_permissions
		return (self.edit_permissions and self.edit_permissions != '')  ? self.edit_permissions : 'Anyone'
	end

	def can_edit(member)
		if member.email == self.author
			return true
		end
		return has_permissions(member, self.get_edit_permissions)
	end

	def can_view(member)
		if member.email == self.author
			return true
		end
		return has_permissions(member, self.get_view_permissions)
	end


	def has_permissions(member, permissions)
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
end

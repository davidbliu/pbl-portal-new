class BlogController < ApplicationController
	def index
		@posts = BlogPost.order('updatedAt desc').all.select{|x| x.can_view(current_member)}
		@editable_ids = @posts.select{|x| x.can_edit(current_member)}.map{|x| x.id}
		puts 'these posts are editable by you'
	end

	def create_post

	end

	def delete_post
		id = params[:id]
		BlogPost.find(id).destroy
		redirect_to '/blog'
	end

	# def save_post
	# 	title = params[:title]
	# 	content = params[:content]
	# 	author = current_member.email
	# 	BlogPost.save_post(nil, title, content, author)
	# 	render nothing:true, status:200
	# end

	def save_post
		id = params[:id]
		puts id 
		puts 'this is the id'
		title = params[:title]
		content = params[:content]
		view_permissions = params[:view_permissions]
		edit_permissions = params[:edit_permissions]
		author = current_member.email
		BlogPost.save_post(id, title, content, author, view_permissions, edit_permissions)
		render nothing:true, status:200
	end

	def email_post
		id = params[:id]
		post = BlogPost.find(id)
		BlogNotifier.send_blog_email(members = ['davidbliu@gmail.com', 'eric.quach@berkeley.edu'], post)
		redirect_to '/blog'
	end

	def edit_post
		id = params[:id]
		@post = BlogPost.find(id)
	end


end
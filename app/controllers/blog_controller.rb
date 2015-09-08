require 'will_paginate/array'
class BlogController < ApplicationController


	def index
		# @posts = BlogPost.order('updatedAt desc').all.select{|x| x.can_view(current_member)}
		@search_term = params[:q]
		if params[:q]
			@posts = BlogPost.search(params[:q])
		else
			@posts = PgPost.order("timestamp desc").all.map{|x| x.to_parse}
			# @posts += PgPost.where("timestamp is null").limit(50).map{|x| x.to_parse.select|x| }
		end
		page = params[:page] ? params[:page] : 1
		@posts = @posts.paginate(:page => page, :per_page => 30)
		@editable_ids = @posts.select{|x| x.can_edit(current_member)}.map{|x| x.id}
		# puts 'these posts are editable by you'
	end


	def view_post
		id = params[:id]
		@post = BlogPost.find(id)
		render 'view_post', layout: false
	end
	def create_post

	end

	def delete_post
		id = params[:id]
		BlogPost.find(id).destroy
		PgBlog.where(parse_id: id).destroy_all
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
		id = (params[:id] and params[:id] != '') ? params[:id] : nil
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
		# BlogNotifier.send_blog_email(members = ['davidbliu@gmail.com', 'eric.quach@berkeley.edu', 'akwan726@gmail.com'], post)
		redirect_to '/blog'
	end

	def edit_post
		id = params[:id]
		@post = BlogPost.find(id)
	end


end
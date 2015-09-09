require 'will_paginate/array'
class BlogController < ApplicationController
	before_filter :authorize

	# , :except => [:index, :redirect_id, :home, :ajax_search]

	def is_admin(member)
		admin_emails = ['davidbliu@gmail.com']
		if member and admin_emails.include?(member.email)
			return true
		end
		return false
	end
	def authorize
		if not current_member
			render 'layouts/authorize', layout: false
		else
			puts current_member.email
		end
	end

	def index
		# @posts = BlogPost.order('updatedAt desc').all.select{|x| x.can_view(current_member)}
		pin = "Pin"
		@pinned = []
		@search_term = params[:q]
		@post_id = params[:post_id]
		if params[:q]
			@filtered = true
			@posts = BlogPost.search(params[:q])
		else
			@posts = PgPost.order("timestamp desc").all.map{|x| x.to_parse}
			# @posts += PgPost.where("timestamp is null").limit(50).map{|x| x.to_parse.select|x| }
		end
		if params[:post_type]
			@post_type = params[:post_type]
			@filtered = true
			@posts = @posts.select{|x| x.get_tags.include?(params[:post_type])}
		end

		if (not params[:post_type]) and (not params[:q])
			@pinned = PgPost.where("tags LIKE ?", "%#{pin}%").to_a.map{|x| x.to_parse}
		end

		@pinned_ids = @pinned.map{|x| x.get_parse_id}
		@posts = @posts.select{|x| x.can_view(current_member)}
		page = params[:page] ? params[:page] : 1
		@posts = @posts.paginate(:page => page, :per_page => 30)
		@editable_ids = @posts.select{|x| x.can_edit(current_member)}.map{|x| x.id}
	end


	def view_post
		id = params[:id]
		@post = BlogPost.find(id)
		render 'view_post'
	end
	def create_post

	end

	def delete_post
		id = params[:id]
		BlogPost.find(id).destroy
		PgPost.where(parse_id: id).destroy_all
		redirect_to '/blog'
	end 

	def save_post
		id = (params[:id] and params[:id] != '') ? params[:id] : nil
		puts id 
		puts 'this is the id'
		title = params[:title]
		content = params[:content]
		view_permissions = params[:view_permissions]
		edit_permissions = params[:edit_permissions]
		post_type = params[:post_type]
		tags = (params[:tags] and params[:tags] != '') ? params[:tags].split(',') : []
		author = current_member.email
		BlogPost.save_post(id, title, content, author, post_type, view_permissions, edit_permissions, tags)
		render nothing:true, status:200
	end

	def email_post
		id = params[:id]
		post = BlogPost.find(id)
		emails = Subscriber.limit(1000000).all.map{|x| x.email}
		BlogNotifier.send_blog_email(members = emails, post)
		redirect_to '/blog'
	end

	def edit_post
		id = params[:id]
		@post = BlogPost.find(id)
	end


end
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

	def cache_link_posts
		BlogPost.all_posts.each do |post|
			if post.get_title[0] == '#'
				Rails.cache.write(post.get_title, post)
			end
		end
		redirect_to '/'
	end

	def post_catalogue
		@posts = BlogPost.limit(100000).all.to_a
	end
	def index
		@pinned = []
		@search_term = params[:q]
		@post_id = params[:post_id]
		if params[:q]
			@filtered = true
			@posts = BlogPost.search(params[:q])
		else
			@posts = BlogPost.all_posts
		end
		if params[:post_type]
			@post_type = params[:post_type]
			@filtered = true
			@posts = @posts.select{|x| x.get_tags.include?(params[:post_type])}
		end

		if (not params[:post_type]) and (not params[:q])
			@pinned = BlogPost.pinned_posts.select{|x| x.can_view(current_member)}
		end
		@pinned_ids = @pinned.map{|x| x.get_parse_id}
		puts @posts.map{|x| x.author}
		page = params[:page] ? params[:page] : 1
		@posts = @posts.select{|x| x.can_view(current_member)}.paginate(:page => page, :per_page => 30)
		@editable_ids = @posts.select{|x| x.can_edit(current_member)}.map{|x| x.id}

		@email_hash = SecondaryEmail.email_lookup_hash
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
		Rails.cache.write('pinned_posts', nil)
		Rails.cache.write('all_posts', nil)
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
		Rails.cache.write('all_posts', nil)
		Rails.cache.write('pinned_posts', nil)


		author = current_member.email
		BlogPost.save_post(id, title, content, author, post_type, view_permissions, edit_permissions, tags)
		render nothing:true, status:200
	end

	def email_landing_page
		id = params[:id]
		@post = BlogPost.find(id)
		@options = BlogPost.email_options
	end
	def email_post
		id = params[:id]
		option = params[:option]
		post = BlogPost.find(id)
		emails = BlogPost.email_options_to_emails(option)
		BlogNotifier.send_blog_email(members = emails, post)
		redirect_to '/blog'
	end

	def edit_post
		id = params[:id]
		@post = BlogPost.find(id)
	end


end
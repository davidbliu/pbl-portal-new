class BlogController < ApplicationController
	def index
		@posts = BlogPost.order('updatedAt desc').all.to_a
	end

	def create_post

	end

	def save_post
		title = params[:title]
		content = params[:content]
		author = current_member.email
		BlogPost.save_post(nil, title, content, author)
		render nothing:true, status:200
	end

	def update_post
		id = params[:id]
		title = params[:title]
		content = params[:content]
		author = current_member.email
		BlogPost.save_post(id, title, content, author)
		render nothing:true, status:200
	end

	def update_and_email
	end

	def edit_post
		id = params[:id]
		@post = BlogPost.find(id)
	end


end
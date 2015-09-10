namespace :blog do
	task :import => :environment do 
		puts 'importing blog posts'
		require 'yaml'
		posts = YAML.load_file('posts_dump.yaml')
		parse_posts = []
		posts.each do |post|
			parse_posts << BlogPost.new(title: post['title'], author: post['email'], content: post['body'], timestamp: post['date'])
			begin
				puts post['body']
			rescue
				puts 'there was an error'
			end
		end
		BlogPost.save_all(parse_posts)
	end

	task :reindex => :environment do 
		BlogPost.import
	end

	task :last_editor => :environment do
		BlogPost.all.each do |post|
			post.last_editor = post.author
			post.save
		end
	end
	task :remove_mistake => :environment do
		puts 'remove posts'
		BlogPost.destroy_all(BlogPost.where(last_editor: nil).to_a)
	end
end


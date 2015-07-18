require 'trello'
require 'set'
class TasksController < ApplicationController

	def home

		# # trello_member_id = 'andreakwan1'
		# trello_member_token = '2db727aef93291576d554f7516cf11e179c9c19b8b4bd7fc755add71ac96556e' # David
		# # trello_member_token = '6a993253e0451753daff16f928c90fdd7c7e1189b48f02298e9dd14bba400ee1' # Andrea

		@member_email_hash = member_email_hash
		email_set = Set.new(@member_email_hash.keys)
		trello_member_id = current_member.trello_id
		trello_member_token = current_member.trello_token
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end

		if trello_member_id and trello_member_token and trello_member_id != '' and trello_member_token != ''
			me = Trello::Member.find(trello_member_id)
			@list_hash = trello_list_hash
			@board_hash = registered_boards
			@cards = me.cards(:filter => :all).select{|x| @board_hash.keys.include?(x.board_id) and @list_hash.keys.include?(x.list_id)}
			@creator_hash = Hash.new
			for card in @cards
				assigned_by = card_assigned_by(card.desc, email_set)
				if assigned_by
					@creator_hash[card.id] = assigned_by
					puts 'assigned_by'
					puts assigned_by
				end
			end
			@trello_member_hash = trello_member_hash
			
			render 'home', :layout => false
		else
			render "no_trello", :layout=>false
		end
	end

	def card_assigned_by(description, email_set)
		if description.include?('{{')
			email =  description.split('{{')[-1].split('}}')[0]
			if email_set.include?(email)
				return email
			end
		end
		return nil
	end

	def card
		card_id = params[:id]
		trello_member_id = current_member.trello_id
		trello_member_token = current_member.trello_token
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end

		@card = Trello::Card.find(card_id)
		puts @card.to_json
		@comments = @card.actions({filter: 'commentCard'})
		@trello_member_hash = trello_member_hash
		@member_email_hash = member_email_hash
		@assigned_by = card_assigned_by(@card.desc, Set.new(@member_email_hash.keys))

		# [{"id":"55a93dd70a2bcdd7a3f94cd1","type":"commentCard","data":{"dateLastEdited":"2015-07-17T18:01:31.640Z","textData":{"emoji":{}},"text":"see checklists toohttps://trello.com/c/RW6bqRrF/33-pay-rent ","card":{"id":"55a931a128036166e7556463","name":"see cards you created","idShort":84,"shortLink":"hfDZb5Vc"},"board":{"id":"55a743ed1ac5db0f968e41fd","name":"PBL Fall 2015","shortLink":"H1gYqoQP"},"list":{"id":"55a743ef2281324196e553f8","name":"Doing"}},"date":"2015-07-17T17:39:35Z","member_creator_id":"541f7c0ad818e679cccd2c07","member_participant":null},{"id":"55a93dd3c1921ec5afd33f3a","type":"commentCard","data":{"list":{"name":"Doing","id":"55a743ef2281324196e553f8"},"board":{"shortLink":"H1gYqoQP","name":"PBL Fall 2015","id":"55a743ed1ac5db0f968e41fd"},"card":{"shortLink":"hfDZb5Vc","idShort":84,"name":"see cards you created","id":"55a931a128036166e7556463"},"text":"also be able to see comments"},"date":"2015-07-17T17:39:31Z","member_creator_id":"541f7c0ad818e679cccd2c07","member_participant":null}]

		render 'card', :layout=>false
	end

	def create
		@trello_members = current_members.select{|x| x.has_trello and x.email}
		puts current_members.select{|x| x.has_trello}.map{|x| x.email}
		puts 'divider'
		puts current_members.select{|x| x.email == 'alice.sun94@gmail.com'}[0].email
		puts current_members.select{|x| x.email == 'alice.sun94@gmail.com'}[0].has_trello
		@unregistered_members = current_members.select{|x| not (x.has_trello and x.email)}
		# see cache helper for how these are computed
		@board_hash = registered_boards
		@main_board = main_board
		@trello_label_hash = trello_label_hash
		@board_members_hash = trello_board_members_hash
		# sorting members by committee
		@member_email_hash = member_email_hash
		@committee_member_hash = committee_member_hash
		@cm_trello_hash = Hash.new
		@committee_member_hash.keys.each do |c|
			emails = @committee_member_hash[c]
			trello_members = Array.new
			emails.each do |email|
				member= @member_email_hash[email]
				if member.has_trello
					trello_members << member
				end
			end
			if trello_members.length >0
				@cm_trello_hash[c] = trello_members
			end
		end

	end


	def guide
	end 

	def clearcache
		clear_tasks_cache
		redirect_to root_path
	end

	def wd_board_id
		'5588dbbc2442c13db37dd6dd'
	end

	def import
		ParseTrelloList.import
		clear_tasks_cache
		redirect_to root_path
	end

	def create_task
		task_name = params[:name]
		task_description = params[:description]
		member_ids = params[:member_ids]
		label_ids = params[:label_ids]
		""" configure Trello for this user """
		trello_member_token = current_member.trello_token # david
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end
		# main_board = ParseTrelloBoard.registered_boards.values.select{|x| x.status=='main'}[0]
		board_id = params[:board_id]
		doing_list = trello_list_hash.values.select{|x| x.name.include?("Doing") and x.board_id == board_id}[0]
		
		# save the creator of the card
		if current_member and current_member.email
			task_description += "\n" + "{{"+current_member.email+"}}"
		end
		card = Trello::Card.create(name: task_name, desc: task_description, member_ids: member_ids.join(','),list_id: doing_list.list_id)
		puts 'saving card'
		card.save
		puts 'adding labels'
		for label_id in label_ids
			label = Trello::Label.find(label_id)
			puts label
			card.add_label(label)
		end

		@card = card
		# render nothing: true, :status=>200
		render 'task_created', :layout=>false

	end

	def update
		@list_hash = trello_list_hash
		@board_hash = registered_boards
		card_id = params[:card_id]
		list_id = params[:list_id]
		board_id  = params[:board_id]
		checked = params[:checked]
		board_lists =  @list_hash.values.select{|x| x.board_id == board_id}

		""" configure Trello for this user """
		trello_member_token = current_member.trello_token # david
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end

		card = Trello::Card.find(card_id)
		if checked == 'true'
			done_list = board_lists.select{|x| x.name.include?("Done")}[0]
			card.list_id = done_list.list_id
		else
			working_list = board_lists.select{|x| x.name.include?("Doing")}[0]
			card.list_id = working_list.list_id
			puts working_list
		end
		card = card.save
		render nothing: true, :status=>200
	end

	def update_trello_info
		if current_member
			current_member.trello_id = params[:id]
			current_member.trello_token = params[:key]

			""" configure Trello for this user """
			if current_member.trello_token != nil and current_member.trello_id != nil and current_member.trello_token != '' and current_member.trello_id != ''
				trello_member_token = current_member.trello_token # david
				Trello.configure do |config|
				  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
				  config.member_token = trello_member_token # The token from step 3.
				end
				me  = Trello::Member.find(current_member.trello_id)
				current_member.trello_member_id = me.id
			end

			current_member.save
			clear_member_cache
		end
		redirect_to '/'
	end

	def register_board
		if params[:board_id]

		end
		trello_member_token = current_member.trello_token # david
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end
		me  = Trello::Member.find(current_member.trello_id)
		@boards = me.boards
	end
end

# https://trello.com/1/authorize?key=bddce21ba2ef6ac469c47202ab487119&name=PBL+Portal+Tasks&expiration=never&response_type=token&scope=read,write

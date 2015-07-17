require 'trello'
class TasksController < ApplicationController

	def home

		# # trello_member_id = 'andreakwan1'
		# trello_member_token = '2db727aef93291576d554f7516cf11e179c9c19b8b4bd7fc755add71ac96556e' # David
		# # trello_member_token = '6a993253e0451753daff16f928c90fdd7c7e1189b48f02298e9dd14bba400ee1' # Andrea

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
				assigned_by = card_assigned_by(card.desc)
				if assigned_by
					@creator_hash[card.id] = assigned_by
					puts 'assigned_by'
					puts assigned_by
				end
			end
			@trello_member_hash = trello_member_hash
			@member_email_hash = member_email_hash
			render 'home', :layout => false
		else
			render "no_trello", :layout=>false
		end
	end

	def card_assigned_by(description)
		if description.include?('<%created_by')
			return description.split('<%created_by')[-1].split('%>')[0].gsub(':', '')
		end
		return nil
	end

	def create
		@trello_members = current_members.select{|x| x.has_trello and x.email}
		@unregistered_members = current_members.select{|x| not (x.has_trello and x.email)}
		# see cache helper for how these are computed
		@board_hash = registered_boards
		@main_board = main_board
		@trello_label_hash = trello_label_hash
		@board_members_hash = trello_board_members_hash
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
			task_description += "\n" + "<%created_by:"+current_member.email+"%>"
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
end

# https://trello.com/1/authorize?key=bddce21ba2ef6ac469c47202ab487119&name=PBL+Portal+Tasks&expiration=never&response_type=token&scope=read,write

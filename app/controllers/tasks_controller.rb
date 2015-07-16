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
			@list_hash = ParseTrelloList.list_hash
			@board_hash = ParseTrelloBoard.registered_boards
			@cards = me.cards(:filter => :all).select{|x| @board_hash.keys.include?(x.board_id) and @list_hash.keys.include?(x.list_id)}

			render 'home', :layout => false
		else
			render "no_trello", :layout=>false
		end
	end

	def create
		@trello_members = member_email_hash.values.select{|x| x.has_trello and x.email}
	end


	def guide
	end 

	def clearcache
		Rails.cache.write('trello_list_hash', nil)
		Rails.cache.write('registered_boards', nil)
		redirect_to root_path
	end

	def wd_board_id
		'5588dbbc2442c13db37dd6dd'
	end

	def import
		ParseTrelloList.import
		Rails.cache.write('trello_list_hash', nil)
		Rails.cache.write('trello_board_hash', nil)
		redirect_to root_path
	end

	def create_task
		task_name = params[:name]
		task_description = params[:description]
		member_ids = params[:member_ids]
		""" configure Trello for this user """
		trello_member_token = current_member.trello_token # david
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end
		main_board = ParseTrelloBoard.registered_boards.values.select{|x| x.status=='main'}[0]
		doing_list = ParseTrelloList.list_hash.values.select{|x| x.name.include?("Doing") and x.board_id == main_board.board_id}[0]
		card = Trello::Card.create(name: task_name, description: task_description, member_ids: member_ids.join(','), list_id: doing_list.list_id)
		card.save

		@card = card
		# render nothing: true, :status=>200
		render 'task_created', :layout=>false

	end

	def update
		@list_hash = ParseTrelloList.list_hash
		@board_hash = ParseTrelloBoard.registered_boards
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

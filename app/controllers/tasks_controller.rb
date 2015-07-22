require 'trello'
require 'set'
class TasksController < ApplicationController

	def home
		@member_email_hash = member_email_hash
		email_set = Set.new(@member_email_hash.keys)
		trello_member_id = current_member.trello_id
		trello_member_token = current_member.trello_token
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end

		if trello_member_id and trello_member_token and trello_member_id != '' and trello_member_token != ''
			# get my boards that are recognized by the portal (in the board hash)
			me = Trello::Member.find(trello_member_id)
			@board_hash = registered_boards
			@boards = me.boards.select{|x| @board_hash.keys.include?(x.id)}.map{|x| @board_hash[x.id]}
			# put main board at front of this list
			@main_board = @boards.select{|x| x.id == main_board.id}[0]
			@boards.delete(@main_board)
			@boards.unshift(@main_board)

			@cards = me.cards(:filter => :all)
			@trello_card_hash = trello_card_hash
			@notifications = me.notifications.map{|x| JSON.parse(x.to_json)}.select{|x| x['unread']}
			render 'home', :layout => false
		else
			render "no_trello", :layout=>false
		end
	end

	def board_cards
		# gets the cards in this board that the member is assigned to
		board_id = params[:board_id]
		trello_member_id = current_member.trello_id
		trello_member_token = current_member.trello_token
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end

		board = Trello::Board.find(board_id)
		@cards = board.cards
		@board_id = board_id

		# get necessary hashes TODO simplify
		@member_email_hash = member_email_hash
		@trello_member_hash = trello_member_hash
		@trello_card_hash = trello_card_hash
		card_id_set = Set.new(@trello_card_hash.keys)

		# filter cards by the ones that are assigned to this member
		@cards = @cards.select{|x| card_id_set.include?(x.id) and @trello_card_hash[x.id].assigned_emails.include?(current_member.email) and not x.member_ids.include?(current_member.trello_member_id)}
		# @cards = @cards.select{|x| card_assigned_to(x.desc, email_set).include?(current_member.email) and not x.member_ids.include?(current_member.trello_member_id)}
		render 'board_cards', :layout=>false
	end

	# """ gets array of all people this card was initially assigned to """
	# def card_assigned_to(description, email_set)
	# 	assigned_emails = Array.new
	# 	if description.include?('$$')
	# 		puts description
	# 		emails =  description.split('$$')[-1].split('$$')[0].split(',')
	# 		emails.each do |email|
	# 			if email_set.include?(email)
	# 				assigned_emails << email
	# 			end
	# 		end
	# 		return assigned_emails
	# 	end
	# 	return Array.new
	# end

	# """ gets person this card was assigned to """
	# def card_assigned_by(description, email_set)
	# 	if description.include?('{{')
	# 		email =  description.split('{{')[-1].split('}}')[0]
	# 		if email_set.include?(email)
	# 			return email
	# 		end
	# 	end
	# 	return nil
	# end

	def card
		card_id = params[:id]
		trello_member_id = current_member.trello_id
		trello_member_token = current_member.trello_token
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end

		@card = Trello::Card.find(card_id)
		@comments = @card.actions({filter: 'commentCard'})
		@trello_member_hash = trello_member_hash
		@member_email_hash = member_email_hash
		if trello_card_hash.keys.include?(@card.id)
			@assigned_by = trello_card_hash[@card.id].assigner_emails
			@assigned = trello_card_hash[@card.id].assigned_emails
		else
			@assigned_by = Array.new
			@assigned = Array.new
		end
		render 'card', :layout=>false
	end

	def create
		@board_id = params[:board_id]
		@main_board = main_board
		if not @board_id or @board_id == ''
			@board_id = @main_board.board_id
		end
		@trello_members = current_members.select{|x| x.has_trello and x.email}
		@unregistered_members = current_members.select{|x| not (x.has_trello and x.email)}
		# see cache helper for how these are computed
		@board_hash = registered_boards
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
		e_hash = member_email_hash
		task_name = params[:name]
		task_description = params[:description]
		member_emails = params[:member_ids]
		# member_ids = params[:member_ids]
		member_ids = member_emails.map{|x| e_hash[x].trello_member_id}
		puts 'your member ids are '
		puts member_ids
		puts 'those '
		label_ids = params[:label_ids]
		""" configure Trello for this user """
		trello_member_token = current_member.trello_token # david
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end
		board_id = params[:board_id]
		doing_list = trello_list_hash.values.select{|x| x.name.include?("Doing") and x.board_id == board_id}[0]
		card = Trello::Card.create(name: task_name, desc: task_description, member_ids: member_ids.join(','),list_id: doing_list.list_id)
		# save the due date
		due_date = params[:due_date]
		if due_date and due_date != ''
			due = DateTime.strptime(due_date, '%d/%m/%Y %H:%M:%S')
			pc_time = Time.parse(due.to_s).utc
			utc_time = pc_time - Time.zone_offset("PDT")
			card.due = utc_time
		end
		puts 'saving card'
		card.save
		puts 'adding labels'
		if label_ids and label_ids != ''
			for label_id in label_ids
				label = Trello::Label.find(label_id)
				puts label
				card.add_label(label)
			end	
		end
		@card = card
		""" save creator and assignees in card object """
		parse_card = ParseTrelloCard.create(card_id: @card.id, board_id: card.board_id, list_id: card.list_id,  assigned_emails: member_emails, assigner_emails: [current_member.email])
		
		clear_card_cache
		# render nothing: true, :status=>200
		render 'task_created', :layout=>false

	end

	def add_comment
		card_id = params[:card_id]
		comment = params[:comment]

		""" configure Trello for this user """
		trello_member_token = current_member.trello_token # david
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end

		card = Trello::Card.find(card_id)
		card.add_comment(comment)

		render nothing: true, :status=>200 
	end

	# for editing
	def pull_labels
		board_id = params[:board_id]
		card_id = params[:card_id]
		@card_id = card_id
		""" configure Trello for this user """
		trello_member_token = current_member.trello_token # david
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end
		card = Trello::Card.find(card_id)
		@card_label_ids = card.card_labels.map{|x| x['id']}
		board = Trello::Board.find(board_id)
		@labels = board.labels(name = false).select{|x| x.name != ""}
		# @labels =  JSON.parse(@labels.to_json)
		render 'pull_labels', :layout=>false
	end

	def update_labels
		card_id = params[:card_id]
		label_ids = params[:label_ids]
		""" configure Trello for this user """
		trello_member_token = current_member.trello_token # david
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end
		card = Trello::Card.find(card_id)
		original_label_ids = card.card_labels.map{|x| x['id']}
		for label_id in label_ids.select{|x| not original_label_ids.include?(x)}
			label = Trello::Label.find(label_id)
			card.add_label(label)
		end
		for label_id in original_label_ids.select{|x| not label_ids.include?(x)}
			label = Trello::Label.find(label_id)
			card.remove_label(label)
		end

		card.save
		render nothing: true, :status=>200 
	end


	def update_description
		card_id = params[:card_id]
		description = params[:description]

		""" configure Trello for this user """
		trello_member_token = current_member.trello_token # david
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		end

		card = Trello::Card.find(card_id)
		card.desc = description
		card.save

		render nothing: true, :status=>200 
	end

	def upload_attachment
		card_id = params[:card_id]
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
		me = Trello::Member.find(current_member.trello_member_id)
		if checked == 'true'
			# done_list = board_lists.select{|x| x.name.include?("Done")}[0]
			# card.list_id = done_list.list_id
			card.remove_member(me)
		else
			# working_list = board_lists.select{|x| x.name.include?("Doing")}[0]
			# card.list_id = working_list.list_id
			# puts working_list
			card.add_member(me)
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
				# add this memeber to the main trello board
				board = Trello::Board.find(main_board.board_id)
				puts board.to_json
				board.add_member(me)
			end

			current_member.save
			clear_member_cache
		end
		redirect_to :back
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

	def label_selector
		board_id = params[:board_id]
	end
end

# https://trello.com/1/authorize?key=bddce21ba2ef6ac469c47202ab487119&name=PBL+Portal+Tasks&expiration=never&response_type=token&scope=read,write

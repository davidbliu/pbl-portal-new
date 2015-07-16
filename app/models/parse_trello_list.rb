require 'trello'
class ParseTrelloList < ParseResource::Base

	fields :name, :list_id, :board_id, :board_name

	def self.due_string(due)
		if due
			due = due+ Time.zone_offset("PDT")
			return due.strftime("%l:%M %p %a %m/%d/%y")
		end
		return ''
	end


	def self.list_hash
		# a = Rails.cache.read('trello_list_hash')
		# if a != nil
		# 	return a
		# end
		a = ParseTrelloList.limit(10000).all.index_by(&:list_id)
		# Rails.cache.write('trello_list_hash', a)
		return a
	end

	def self.import
		lists = Array.new
		all_boards = Array.new
		seen_board_ids = Array.new
		ParseMember.email_hash.values.each do |member|
			if member.trello_token and member.trello_id and member.trello_token != '' and member.trello_id != ''
				Trello.configure do |config|
				  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119'
				  config.member_token = member.trello_token
				end

				me = Trello::Member.find(member.trello_id)

				""" save the member_id for fast access """
				if member.trello_member_id == nil
					member_id = me.id
					member.trello_member_id = member_id
					member.save
				end

				""" go through all of the members boards and save all boards, lists, and labels """ 
				me.boards.each do |board|
					if not seen_board_ids.include?(board.id)
						puts 'This is your board: '  + board.name
						seen_board_ids << board.id
						# save all the lists in this board
						board.lists.each do |list|
							puts "\t" + list.name
							lists << ParseTrelloList.new(name: list.name, list_id: list.id, board_name: board.name, board_id: board.id)
						end

						#save all the members in this board
						members = board.members
						member_usernames =  members.map{|x| x.username}
						member_ids = members.map{|x| x.id}
						# get all labels in board
						# labels = JSON.parse(board.labels.to_json)
						# valid_labels = Hash.new
						# labels.keys.each do |color|
						# 	if labels[color] != ""
						# 		valid_labels[labels[color]] = color
						# 	end
						# end
						all_boards << ParseTrelloBoard.new(name: board.name, board_id: board.id, status: '', labels: board.labels.to_json.to_s, member_usernames: member_usernames, member_ids: member_ids)
					end
				end
			end
		end
		puts 'saving lists'
		ParseTrelloList.destroy_all
		ParseTrelloList.save_all(lists)
		puts 'saving boards'
		ParseTrelloBoard.destroy_all
		ParseTrelloBoard.save_all(all_boards)

		return true
	end
end

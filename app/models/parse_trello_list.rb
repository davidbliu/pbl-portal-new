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
		a = Rails.cache.read('trello_list_hash')
		if a != nil
			return a
		end
		a = ParseTrelloList.limit(10000).all.index_by(&:list_id)
		Rails.cache.write('trello_list_hash', a)
		return a
	end

	def self.import
		lists = Array.new
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

				me.boards.each do |board|
					if not seen_board_ids.include?(board.id)
						puts board.name
						puts board.id.to_s
						seen_board_ids << board.id
						board.lists.each do |list|
							puts list.name + list.id.to_s
							lists << ParseTrelloList.new(name: list.name, list_id: list.id, board_name: board.name, board_id: board.id)
						end
					end
				end
			end
		end
		puts 'saving lists'
		ParseTrelloList.destroy_all
		ParseTrelloList.save_all(lists)
		seen_board_ids = Array.new
		boards = Array.new
		ParseTrelloList.limit(10000).all.each do |list|
			if not seen_board_ids.include?(list.board_id)
				seen_board_ids << list.board_id 
				board = ParseTrelloBoard.new(name: list.board_name, board_id: list.board_id, status: "")
				boards << board
				puts board.name
			end
		end
		puts 'saving boards....'
		ParseTrelloBoard.destroy_all
		ParseTrelloBoard.save_all(boards)
		return true
	end
end

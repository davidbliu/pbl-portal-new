require 'trello'
class ParseTrelloList < ParseResource::Base

	fields :name, :list_id, :board_id, :board_name

	def self.due_string(due)
		due ? due.strftime("%a %m/%d/%y at %H:%M") : ''
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

	def self.board_hash
		a = Rails.cache.read('trello_board_hash')
		if a != nil
			return a
		end
		a = Hash.new
		ParseTrelloList.list_hash.values.each do |elem|
			if not a.keys.include?(elem.board_id)
				a[elem.board_id] = elem.board_name
			end
		end
		Rails.cache.write('trello_board_hash', a)
		return a
	end

	def self.board_lists
		list_hash = ParseTrelloList.list_hash
		h = Hash.new
		self.board_hash.keys.each do |board_id|
			h[board_id] = list_hash.values.select{|y| y.board_id == board_id}
		end
		return h
	end

	def self.board_ids
		# self.list_hash.values.map{|x| x.board_id}
		return ['5588dbbc2442c13db37dd6dd', '5539e97cba55f9125828d4e6']
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
		return true
	end
end

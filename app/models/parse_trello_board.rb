require 'trello'
class ParseTrelloBoard < ParseResource::Base
	fields :board_id, :name, :status, :member_ids, :member_usernames, :labels

	def self.registered_boards
		a = ParseTrelloBoard.limit(1000).all.select{|x| x.status == 'registered' or x.status == 'main'}.index_by(&:board_id)
		return a
	end

	def self.label_hash
		h = Hash.new
		self.registered_boards.values.each do |board|
			h[board.board_id] = board.get_labels
		end
		return h
	end

	# value is list iof member ids
	def self.board_members_hash
		h = Hash.new
		self.registered_boards.values.each do |board|
			h[board.board_id] = board.member_ids
		end
		return h
	end

	def self.main_board
		return self.registered_boards.values.select{|x| x.status=='main'}[0]
	end

	def get_labels
		labels = JSON.parse(self.labels)
		valid_labels = Hash.new
		labels.keys.each do |color|
			if labels[color] != ""
				valid_labels[labels[color]] = color
			end
		end
		return valid_labels
	end
end
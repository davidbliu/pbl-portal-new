require 'trello'
class ParseTrelloBoard < ParseResource::Base
	fields :board_id, :name, :status

	def self.registered_boards
		a = Rails.cache.read('registered_boards')
		if a != nil
			return a
		end
		a = ParseTrelloBoard.limit(1000).all.select{|x| x.status == 'registered' or x.status == 'main'}.index_by(&:board_id)
		Rails.cache.write('registered_boards', a)
		return a
	end


end
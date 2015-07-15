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

	def self.board_ids
		# self.list_hash.values.map{|x| x.board_id}
		return ['5588dbbc2442c13db37dd6dd']
	end

	def self.import
		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = 'a8ce658eb73365a1981c07da5c736196dab1e61539d28ea8ac146ad4521d8d93' #davids
		  # config.member_token = '6a993253e0451753daff16f928c90fdd7c7e1189b48f02298e9dd14bba400ee1' #andreas
		end

		me = Trello::Member.find('davidliu42')

		lists = Array.new
		me.boards.each do |board|
			puts board.name
			puts board.id.to_s
			board.lists.each do |list|
				puts list.name + list.id.to_s
				lists << ParseTrelloList.new(name: list.name, list_id: list.id, board_name: board.name, board_id: board.id)
			end
		end
		puts 'saving lists'
		ParseTrelloList.destroy_all
		ParseTrelloList.save_all(lists)
		return true
	end
end

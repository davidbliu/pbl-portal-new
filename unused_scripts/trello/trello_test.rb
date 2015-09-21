require 'trello'
emily_token = '1a5a87f019d28e57630d0d90cc6f74e4af26918c00ed91426324169a8de4f050'
david_token = 'a8ce658eb73365a1981c07da5c736196dab1e61539d28ea8ac146ad4521d8d93'
Trello.configure do |config|
  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
  config.member_token = emily_token # The token from step 3.
end


board_id = '5588dbbc2442c13db37dd6dd'
# bob = Trello::Member.find("bobtester")
# boards = Trello::Board.find(board_id)

me = Trello::Member.find('emilyliu10')

my_cards = me.cards(:filter => :all).select{|x| x.board_id == board_id}
my_cards.each do |card|
	puts '* ' + card.name + ' closed? ' + card.closed?.to_s + ' label: ' + card.card_labels.map{|x| x['name']}.to_s
	# puts "\t" + card.due.to_s
	# puts "\t" + card.desc.to_s
	# puts "\t" + card.board_id
end

me.boards.each do |board|
	board.lists.each do |list|
		puts list.name + list.id.to_s
		list.cards.each do |card|
			puts "\t" + card.name
		end
	end
end

puts 'done'

puts me.actions.to_json

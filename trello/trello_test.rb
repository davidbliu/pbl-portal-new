require 'trello'

Trello.configure do |config|
  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
  config.member_token = 'a8ce658eb73365a1981c07da5c736196dab1e61539d28ea8ac146ad4521d8d93' # The token from step 3.
end

board_id = '5588dbbc2442c13db37dd6dd'
# bob = Trello::Member.find("bobtester")
# boards = Trello::Board.find(board_id)
me = Trello::Member.find('davidliu42')

my_cards = me.cards(:filter => :all).select{|x| x.board_id == board_id}
my_cards.each do |card|
	puts '* ' + card.name + ' closed? ' + card.closed?.to_s + ' label: ' + card.card_labels.map{|x| x['name']}.to_s
	# puts "\t" + card.due.to_s
	# puts "\t" + card.desc.to_s
	# puts "\t" + card.board_id
end
puts 'done'

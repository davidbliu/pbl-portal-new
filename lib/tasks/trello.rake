namespace :trello do
  task :boards => :environment do
  	puts 'getting boards'
  	parse_boards = ParseTrelloBoard.all.to_a

  	puts 'setting up trello account'
  	Trello.configure do |config|
	  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
	  config.member_token = 'a8ce658eb73365a1981c07da5c736196dab1e61539d28ea8ac146ad4521d8d93' # The token from step 3.
	end

  	parse_boards.each do |board|
  		puts 'pulling trello board'
  		begin
  			trello_board = Trello::Board.find(board.board_id)
  			# puts trello_board
  			cards = trello_board.cards
  			cards.each do |card|
  				puts "\t"+card.name
  			end
  		rescue
  			puts 'no access to this board'
  		end
  	end
  	puts parse_boards
  end

  task :migrate_tasks => :environment do
  	puts 'not implemented yet'
  end
end
require 'trello'
class TasksController < ApplicationController

	def home
		trello_member_id = 'davidliu42'
		# trello_member_id = 'andreakwan1'
		trello_member_token = 'a8ce658eb73365a1981c07da5c736196dab1e61539d28ea8ac146ad4521d8d93' # David
		# trello_member_token = '6a993253e0451753daff16f928c90fdd7c7e1189b48f02298e9dd14bba400ee1' # Andrea

		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		  # config.member_token = '6a993253e0451753daff16f928c90fdd7c7e1189b48f02298e9dd14bba400ee1' #andreas
		end
		# me = Trello::Member.find('andreakwan1')
		me = Trello::Member.find(trello_member_id)

		@cards = me.cards(:filter => :all)
		@list_hash = ParseTrelloList.list_hash
		render 'home', :layout => false
	end

	def wd_board_id
		'5588dbbc2442c13db37dd6dd'
	end
end
require 'trello'
class TasksController < ApplicationController

	def home
		trello_member_id = 'davidliu42'
		# trello_member_id = 'andreakwan1'
		trello_member_token = '2db727aef93291576d554f7516cf11e179c9c19b8b4bd7fc755add71ac96556e' # David
		# trello_member_token = '6a993253e0451753daff16f928c90fdd7c7e1189b48f02298e9dd14bba400ee1' # Andrea

		Trello.configure do |config|
		  config.developer_public_key = 'bddce21ba2ef6ac469c47202ab487119' # The "key" from step 1
		  config.member_token = trello_member_token # The token from step 3.
		  # config.member_token = '6a993253e0451753daff16f928c90fdd7c7e1189b48f02298e9dd14bba400ee1' #andreas
		end
		# me = Trello::Member.find('andreakwan1')
		me = Trello::Member.find(trello_member_id)

		@cards = me.cards(:filter => :all).select{|x| ParseTrelloList.board_ids.include?(x.board_id) }
		@list_hash = ParseTrelloList.list_hash
		render 'home', :layout => false
	end

	def guide
	end 

	def clearcache
		Rails.cache.write('trello_list_hash', nil)
		redirect_to root_path
	end

	def wd_board_id
		'5588dbbc2442c13db37dd6dd'
	end
end

# https://trello.com/1/authorize?key=bddce21ba2ef6ac469c47202ab487119&name=PBL+Portal+Tasks&expiration=never&response_type=token&scope=read,write

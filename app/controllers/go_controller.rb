class GoController < ApplicationController
	def go
		puts 'printing param keys'
		puts params.keys()[0]
		puts 'that was the key'
		go_hash = go_link_hash
		go_key = params.keys()[0]
		if go_hash.keys.include?(go_key)
			redirect_to go_hash[go_key]
		end

		@go_key
		@go_hash
	end

	def go_link_hash
		go_hash = Hash.new
		go_hash['tabling'] = "http://testing.berkeley-pbl.com/tabling"
		go_hash['points'] = "http://testing.berkeley-pbl.com/points"
		go_hash['neon'] = "https://drive.google.com/drive/folders/0BwLZUlGsG71OflJGRUphZHpyOEJNWXNIbnVXUFFMTkxBcXBIQWRBT0xxMVVKbnlHVjZTM28"
		return go_hash
	end
end
class ParseGoLinkRating < ParseResource::Base
	fields :key, :golink_id, :rating, :upvoted, :downvoted


	def self.upvote_link(golink_id, email)
		golink = ParseGoLink.find(golink_id)
		rating = ParseGoLinkRating.where(golink_id: golink_id).to_a
		if rating.length == 0
			rating = ParseGoLinkRating.new(key: golink.key, golink_id: golink_id, rating: 0, upvoted: '', downvoted: '')
		else	
			rating = rating[0]
		end

		upvoted = rating.upvoted.split(',')
		downvoted = rating.downvoted.split(',')

		if not upvoted.include?(email)
			upvoted.push(email)
		end
		downvoted.delete(email)
		rating.rating = upvoted.length - downvoted.length
		rating.upvoted = upvoted.join(',')
		rating.downvoted = downvoted.join(',')
		rating.save

		# save the data in the golink too
		golink.rating = rating.rating
		golink.votes = upvoted.length + downvoted.length
		golink.save

		# save the data in postgres golink too
		gl = GoLink.where(parse_id: golink.id).first
		if gl
			gl.votes = golink.votes
			gl.rating = golink.rating
			gl.save
		end
	end

	def self.downvote_link(golink_id, email)
		golink = ParseGoLink.find(golink_id)
		rating = ParseGoLinkRating.where(golink_id: golink_id).to_a
		if rating.length == 0
			rating = ParseGoLinkRating.new(key: golink.key, golink_id: golink_id, rating: 0, upvoted: '', downvoted: '')
		else	
			rating = rating[0]
		end

		upvoted = rating.upvoted.split(',')
		downvoted = rating.downvoted.split(',')

		if not downvoted.include?(email)
			downvoted.push(email)
		end
		upvoted.delete(email)
		rating.rating = upvoted.length - downvoted.length
		rating.upvoted = upvoted.join(',')
		rating.downvoted = downvoted.join(',')
		rating.save

		# save the data in the golink too
		golink.rating = rating.rating
		golink.votes = upvoted.length + downvoted.length
		golink.save

		# save the data in postgres golink too
		gl = GoLink.where(parse_id: golink.id).first
		if gl
			gl.votes = golink.votes
			gl.rating = golink.rating
			gl.save
		end
	end

	


end
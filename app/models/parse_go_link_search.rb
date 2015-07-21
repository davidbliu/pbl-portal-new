class ParseGoLinkSearch < ParseResource::Base

	fields :member_email, :time, :search_term, :type, :results
	# type refers to if if was from the chrome extension



end
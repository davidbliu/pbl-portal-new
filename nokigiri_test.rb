require 'nokogiri'
require 'open-uri'

def get_url_fulltext(url)
	html = Nokogiri::HTML(open url)
	text  = html.at('body').inner_text
	# Pretend that all words we care about contain only a-z, 0-9, or underscores
	words = text.scan(/\w+/)
	# words that are only letters
	# words = text.scan(/[a-z]+/i)
	fulltext = ''
	words.each do |word|
		fulltext += word + ' '
	end
	return fulltext.gsub(/\s+/, ' ')
end

def get_fulltext(url)
	page = Nokogiri::HTML(open url)
	links = page.css("a").map{|x| x.text}
	puts links

	divs = page.css("div")
	divs.each do |div|
		puts div.text
	end

	
	# puts divs
end

puts get_fulltext('https://github.com/davidbliu/pbl-portal-new')

# p words.length, words.uniq.length, words.uniq.sort[0..8]
#=> 907
#=> 428
#=> ["0", "1", "100", "15px", "2", "20", "2011", "220px", "24158nokogiri"]

# How about words that are only letters?
# words = text.scan(/[a-z]+/i)
# p words.length, words.uniq.length, words.uniq.sort[0..5]
#=> 872
#=> 406
#=> ["Answer", "Ask", "Badges", "Browse", "DocumentFragment", "Email"]
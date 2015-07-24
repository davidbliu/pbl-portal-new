require 'mechanize'
require 'nokogiri' 

mechanize = Mechanize.new

page = mechanize.get('http://www.bbc.co.uk/news/')

page_body = page.body

doc = Nokogiri::HTML(page.body)

doc.css('div').map do |div|
	puts div
end

# puts doc

# puts ActionView::Base.full_sanitizer.sanitize(page.body)
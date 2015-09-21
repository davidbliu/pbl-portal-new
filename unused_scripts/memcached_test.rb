require 'dalli'
options = { :namespace => "app_v1", :compress => true }
dc = Dalli::Client.new('localhost:11211', options)
dc.set('abc', 123)
value = dc.get('abc')
puts value

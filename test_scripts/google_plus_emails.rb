require 'google_plus'
GooglePlus.api_key = 'AIzaSyC6qO8YSQZZX4uzuL9jKtOaQw9X55f0Irg'

person = GooglePlus::Person.get('118157609286249259662')
puts person.inspect
puts person.emails
puts 'that is all'


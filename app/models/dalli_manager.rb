require 'timeout'
class DalliManager

	def self.dalli_client
		options = { :namespace => "app_v1", :compress => true }
    	dc = Dalli::Client.new(ENV['MEMCACHED_HOST'], options)
    	return dc
	end
end
require 'timeout'
require 'set'
class Commitments < ParseResource::Base
	fields :member_email, :commitments

	def self.get_commitments(email)
		commitments = Commitments.where(member_email:email).to_a
		if commitments.length == 0
			return self.rand_n(30, 167)
		end
		return commitments[0].commitments.map{|x| x.to_i}
		
	end

	def self.commitments_hash
		Rails.cache.fetch 'commitments_hash' do 
			commitments = Commitments.limit(100000).all.index_by(&:member_email)
			c = {}
			ParseMember.current_members.each do |cm|
				if commitments.keys.include?(cm.email)
					c[cm.email] = commitments[cm.email].commitments.map{|x| x.to_i}
				else
					c[cm.email] = []
				end
			end
			return c
		end
	end

	def self.rand_n(n, max)
		randoms = Set.new
		loop do
			randoms << rand(max)
			return randoms.to_a if randoms.size >= n
		end
	end
	
end
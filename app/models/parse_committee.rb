class ParseCommittee < ParseResource::Base

	fields :name, :abbr, :old_id

	def self.hash
		ParseCommittee.all.index_by(&:id)
	end
	def self.old_hash
		ParseCommittee.all.index_by(&:old_id)
	end
	def self.migrate
		committees = Array.new
		Committee.all.each do |c|
			puts c.name
			pc = ParseCommittee.new
			pc.name = c.name
			pc.abbr  = c.abbr
			pc.old_id = c.idC
			committees << pc
		end
		ParseCommittee.save_all(committees)
	end
end

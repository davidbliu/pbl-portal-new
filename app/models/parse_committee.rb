class ParseCommittee < ParseResource::Base

	fields :name, :abbr, :old_id

	def self.hash
		chash = Rails.cache.read('committee_hash')
		if chash != nil
			return chash
		end

		chash = ParseCommittee.all.index_by(&:id)
		Rails.cache.write('committee_hash', chash)
		return chash
	end
	def self.old_hash
		ParseCommittee.all.index_by(&:old_id)
	end

	""" committee convenience """
	def self.gm
		gm = Rails.cache.read('gm')
		if gm != nil
			return gm
		end
		gm = ParseCommittee.where(name: 'General Members').first
		Rails.cache.write('gm', gm)
		return gm
	end


	def self.alphabetized_ids
		ParseCommittee.all.sort_by{|x| x.name}.map{|x| x.id}
	end

	""" migration method """
	def self.migrate
		committees = Array.new
		Committee.all.each do |c|
			puts c.name
			pc = ParseCommittee.new
			pc.name = c.name
			pc.abbr  = c.abbr
			pc.old_id = c.id
			committees << pc
		end
		ParseCommittee.save_all(committees)
	end
end

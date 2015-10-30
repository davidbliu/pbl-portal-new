require 'set'
class GoStat < ParseResource::Base
	fields :name, :data, :other
	MAXINT = (2**(0.size * 8 -2) -1)
	def self.get_key(key)
		stat = GoStat.where(name:key).to_a
		if stat.length == 0
			return nil
		end
		return JSON.parse(stat[0].data)
	end

	def self.put_key(key, result)
		stat = GoStat.where(name:key).to_a
		if stat.length == 0
			stat = GoStat.new(name: key)
		else
			stat = stat[0]
		end
		stat.data = result
		stat.save
	end

	def self.top_recent
		tr = self.get_key('top_recent')
		return tr ? tr : []
	end	

	def self.contributors
		c = self.get_key('contributors')
		return c ? c : []
	end

	def self.tags
		return self.get_key('tags')
	end

	""" calculate methods """

	def self.calculate_top_recent
          last_clicks = ParseGoLinkClick.order('createdAt desc').limit(1000).all.to_a
          click_hash = {}
          last_clicks.each do |click|
                  if not click_hash.keys.include?(click.golink_id)
                          click_hash[click.golink_id] = 0
                  end
                  click_hash[click.golink_id] += 1
          end
          golinks = GoLink.where("parse_id in (?)", click_hash.keys)
          results = []
          golinks.each do |golink|
              gl = golink.to_parse
              results << {'num_clicks' => click_hash[gl.get_parse_id], 'golink'=> gl.to_json}
          end
          # puts golinks
          self.put_key('top_recent', results.to_json)
	end

	def self.recent_contributors
	end

	def self.calculate_contributors
		# list of contributors: member, viewed, added
		# clicks = ParseGoLinkClick.limit(MAXINT).all.to_a
		golinks = ParseGoLink.limit(MAXINT).all.to_a
		puts 'fetched golinks'
		adders = {}
		golinks.each do |golink|
			puts golink.key
                        if golink.member_email
                            if not adders.keys.include?(golink.member_email)
                                      adders[golink.member_email] = 0
                            end
                            adders[golink.member_email] += 1
                        end
		end
		contributors = []
		adders.keys.each do |c|
			contributors << {'email'=>c, 'num_added'=> adders[c]}
		end
		self.put_key('contributors', contributors.to_json)
	end

	def self.calculate_tags
		tags = []
		ParseGoLink.limit(MAXINT).all.each do |golink|
			tags.push(*golink.get_tags)  
		end
		tags = Set.new(tags).to_a
		puts tags
		self.put_key('tags', tags.to_json)
	end

end

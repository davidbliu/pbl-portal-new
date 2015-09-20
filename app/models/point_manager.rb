 class PointManager < ActiveRecord::Base
	attr_accessible :semester_id
	belongs_to :semester, foreign_key: :semester_id

	
	def self.get_points(email)
		a = Rails.cache.read(email+'_points')
		if a
			return a
		end
		points = Hash.new
		attended_events = PointManager.attended_events(email)
		pts = attended_events.map{|x| x.get_points}.inject{|sum,x| sum + x }
		points['points'] = pts
		points['attended'] = attended_events
		Rails.cache.write(email+'_points', points)
		return points
	end
	def self.get_type(type)
		if type == 'exec'
			return chair
		end
		return type
	end
	
	def self.attended_events(email)
		""" gets the events that this member attended """
		events = ParseEvent.limit(1000).where(semester_name: ParseSemester.current_semester.name)
		member_events = ParseEventMember.limit(1000).where(member_email: email).select{|x| x.type == 'chair' or x.type == 'exec'}
		eids = member_events.map{|x| x.event_id}
		attended = events.select{|x| eids.include?(x.google_id)}
		return attended
	end

	def self.points(member_id)
		""" gets this member's points """

		events = self.attended_events(member_id)
		return events.pluck(:points).sum
	end

	def self.member_point_dict(semester = Semester.current_semester)
		""" returns a dict of keys member ids and values points """

		m_point_dict = Rails.cache.read('member_point_dict')
		if m_point_dict != nil
			return m_point_dict
		end
		m_point_dict = Hash.new
		Member.current_members(semester).all.each do |member|
			m_point_dict[member.id] = points(member.id)
		end
		Rails.cache.write('member_point_dict', m_point_dict)
		return m_point_dict
	end

	def self.member_name_point_dict(semester = Semester.current_semester)
		""" returns a dict of member name to member points""" 

		npd = Rails.cache.read('member_name_point_dict')
		if npd != nil
			return npd
		end
		npd = Hash.new
		member_hash = Member.member_hash
		member_point_dict = self.member_point_dict(semester)
		member_point_dict.keys.each do |mid|
			npd[member_hash[mid].name] = member_point_dict[mid]
		end
		Rails.cache.write('member_name_point_dict', npd)
		return npd
	end

	def self.top_cms(semester = Semester.current_semester)
		current_cms = Member.current_cms(semester)
		point_dict = self.member_point_dict
		return current_cms.sort_by{|member| -point_dict[member.id]}
	end

	""" Hidden Methods """

	def self.event_members(member_id)
		""" returns the event_members for this member_id """
		this_semester_events = Event.this_semester.pluck(:id)
		ems = EventMember.where('event_id in (?)', this_semester_events).where(member_id: member_id)
		return ems
	end




end

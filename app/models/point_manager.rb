class PointManager < ActiveRecord::Base
	attr_accessible :semester_id
	belongs_to :semester, foreign_key: :semester_id

	def self.event_members(member_id)
		""" returns the event_members for this member_id """

		this_semester_events = Event.this_semester.pluck(:id)
		ems = EventMember.where('event_id in (?)', this_semester_events).where(member_id: member_id)
		return ems
	end

	def self.attended_events(member_id)
		""" gets the events that this member attended """

		ems = PointManager.event_members(member_id)
		events = Event.this_semester.where('id in (?)', ems.pluck(:event_id))
		return events
	end

	def self.points(member_id)
		""" gets this member's points """

		events = self.attended_events(member_id)
		return events.pluck(:points).sum
	end

	def self.member_point_dict
		""" returns a dict of keys member ids and values points """

		m_point_dict = Rails.cache.read('member_point_dict')
		if m_point_dict != nil
			return m_point_dict
		end
		m_point_dict = Hash.new
		Member.current_members.all.each do |member|
			m_point_dict[member.id] = points(member.id)
		end
		Rails.cache.write('member_point_dict', m_point_dict)
		return m_point_dict
	end

	def self.member_name_point_dict
		npd = Rails.cache.read('member_name_point_dict')
		if npd != nil
			return npd
		end
		npd = Hash.new
		member_hash = Member.member_hash
		member_point_dict = self.member_point_dict
		member_point_dict.keys.each do |mid|
			npd[member_hash[mid].name] = member_point_dict[mid]
		end
		Rails.cache.write('member_name_point_dict', npd)
		return npd
	end




end

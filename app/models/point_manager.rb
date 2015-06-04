class PointManager < ActiveRecord::Base
	attr_accessible :semester_id
	belongs_to :semester, foreign_key: :semester_id

	$this_semester_events = Event.this_semester.pluck(:id)
	def self.current_manager(semester = Semester.current_semester)
		return PointManager.where(semester_id: semester.id).first
	end

	def event_members(member_id)
		# this_semester_events = Event.this_semester.pluck(:id)
		$this_semester_events
		ems = EventMember.where('event_id in (?)', $this_semester_events).where(member_id: member_id)
		return ems
	end

	def attended_events(member_id)
		ems = self.event_members(member_id)
		events = Event.this_semester.where('id in (?)', ems.pluck(:event_id))
		return events
	end

	def points(member_id)
		events = self.attended_events(member_id)
		return events.pluck(:points).sum
	end





end

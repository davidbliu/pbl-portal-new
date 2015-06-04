class Event < ActiveRecord::Base
  attr_accessible :name, :start_time, :end_time, :description, :semester_id, :google_id
  belongs_to :semester, foreign_key: :semester_id
  has_one :event_points #, dependent: :destroy
  has_many :event_members #, dependent: :destroy

  scope :this_semester, -> {where(semester_id: Semester.current_semester.id)}

  def self.this_semester
    return Event.where(semester_id: Semester.current_semester.id)
  end

  def points
  	points = EventPoints.where(event_id: self.id.to_s)
  	if points.length != 0
  		return points.first.value
  	end
  	return 0
  end

  def set_points(value)
    EventPoints.where(event_id: self.id.to_s).destroy_all
    point = EventPoints.new
    point.event_id = self.id
    point.value = value
    point.semester_id = Semester.current_semester.id
    point.save
  end
  def attendees
    event_mem_ids = EventMember.where(event_id: self.id.to_s).pluck(:member_id)
    return Member.where('id IN (?)', event_mem_ids)
  end

  def attendance_rate(committee)
    attendees = self.attendees
    cms = Member.currently_in_committee(committee).pluck(:id)
    total_cms = cms.length
    count = attendees.where('id IN (?)', cms).length
    return [count, total_cms, (count.to_f/total_cms)]
  end
end

class Event < ActiveRecord::Base
  # attr_accessible :name, :start_time, :end_time, :description, :semester_id, :google_id
  belongs_to :semester, foreign_key: :semester_id
  has_one :event_points #, dependent: :destroy
  has_many :event_members #, dependent: :destroy
  has_many :blog_events
  has_many :posts, :through => :blog_events

  scope :this_semester, -> {where(semester_id: Semester.current_semester.id)}
  def points
  	points = EventPoints.where(event_id: self.id.to_s)
  	if points.length != 0
  		return points.first.value
  	end
  	return 0
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

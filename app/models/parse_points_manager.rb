class ParseTablingSlot < ParseResource::Base
  fields :member_ids, :time, :member_emails

  def self.get_member_points(member, semester = Semester.current_semester)
  end

  def self.get_points_dict(semester = Semester.current_semester)
  	
  end
end

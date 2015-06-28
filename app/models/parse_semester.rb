
class ParseSemester < ParseResource::Base
  fields :name, :start_time, :end_time, :old_id

  def self.current_semester
    semester = Rails.cache.read('current_semester')
    if semester != nil
      return semester
    end
    # make 1 call to parse
    semester = ParseSemester.all.sort_by{|x| x.start_time}.reverse.first
    Rails.cache.write('current_semester', semester)
    return semester
  end

  def self.hash
    return ParseSemester.all.index_by(&:id)
  end

  def self.old_hash
    return ParseSemester.all.index_by(&:old_id)
  end


  def self.migrate
  	Semester.all.each do |semester|
  		ps = ParseSemester.new
  		ps.start_time = semester.start_date
  		ps.end_time = semester.end_date
  		ps.name = semester.name
      ps.old_id = semester.id
  		puts semester.name
  		ps.save
  	end
  end

end

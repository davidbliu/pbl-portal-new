task :migrate_member => :environment do
  p 'hi'
  # events = Event.all
  current_member = Member.where(name: "David Liu").first
  # p current_member.attendance_id_mapping(events)
  # OldMember.all.each do |m|
  #   p m.first_name
  # end
  p 'there are '+OldMember.all.length.to_s+' old members'
  p 'there are '+Member.all.length.to_s+' members in the current portal'


  p OldMember.column_names
  p Member.column_names
end


task :initial_migrate => :environment do
  Member.all.each do |mem|
    if mem.old_member_id
      old = mem.old_member_id
      if old
        om = OldMember.find(old)
        # mem.email = om.email
        mem.phone = om.phone
        mem.sex = om.sex
        mem.blurb = om.blurb
      end
      mem.save
    else
      p 'no old member '+mem.name
      # p mem.name
    end

  end
end

task :migrate_all => :environment do
  old_mem_ids = Member.where("old_member_id IS NOT NULL").pluck(:old_member_id)
  query = OldMember.where('id NOT IN (?)', old_mem_ids).all
  query.each do |om|
    m = Member.create()
    name = om.first_name+' '+om.last_name
    old_id = om.id
    email = om.email
    phone = om.phone
    provider = 'none'
    uid = 'none'
    member = Member.new
    member.name = name
    member.old_member_id = old_id
    member.email = email
    member.phone = phone
    member.provider = provider
    member.uid = uid

    member.save
    p 'saved '+name
    # p m
  end
  # results = ActiveRecord::Base.connection.select_all(query)
  # p results
  # p query
end

task :count => :environment do
  p Member.all.length
end

task :add_old_to_alum => :environment do
  Member.all.each do |member|

  end 
end

task :join => :environment do
  join = CommitteeMember.where(semester: Semester.current_semester).joins(:member, :committee, :committee_member_type)
  mems = join.map{|j| {'name'=>j.member.name,'position'=> j.member.position, 'committee'=>j.committee.name}}
  p mems
end

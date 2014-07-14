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
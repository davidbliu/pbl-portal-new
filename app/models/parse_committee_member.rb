class ParseCommitteeMember < ParseResource::Base

  fields :committee_id, :member_id, :semester_id, :position_id


  def self.migrate
    member_hash = ParseMember.old_hash
    committee_hash = ParseCommittee.old_hash
    semester_hash = ParseSemester.old_hash
    committee_members = Array.new
    CommitteeMember.all.each do |x|
      begin
        puts committee_hash[x.committee_id].id
        puts member_hash[x.member_id].id
        cm = ParseCommitteeMember.new
        cm.committee_id = committee_hash[x.committee_id].id
        cm.member_id = member_hash[x.member_id].id
        cm.semester_id = semester_hash[x.semester_id].id
        cm.position_id = x.position_id
        puts cm
        committee_members << cm
      rescue
        puts 'error'
      end
    end
    puts committee_members.length.to_s + ' to be saved'
    ParseCommitteeMember.save_all(committee_members)
    puts ParseCommitteeMember.limit(10000).all.length.to_s + ' saved'
    return 'done'
  end




  """ Position of this committee member object (chair, cm, gm, exec) """
  def position
    return CommitteeMemberPosition.positions[self.position_id]
  end

  def role
    return self.position.name
  end

  def tier
    return self.position.tier
  end

  def permissions
    return self.position.permissions
  end

end
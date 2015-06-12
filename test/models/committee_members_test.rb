require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase

""" test positions """

  test 'basic position test' do
  	committee_member = committee_members(:cm1)
  	assert committee_member.position.kind_of?(CommitteeMemberPosition), 'the position should be a kind of CommitteeMemberPosition'
  	assert committee_member.role == 'chair', committee_member.position.name + ' should be a chair but was ' + committee_member.role.to_s
  	assert committee_member.permissions == 2, 'permissions should be 2'
  end

  test 'committee member convenience methods work' do 
  	member = members(:david)
    # p 'this was the position'
    # p member.name
    # p member.id
    # p member.current_committee.name
    # p member.position.name
    # p member.position.abbr
    # p member.position.tier
    # p member.position.permissions
  	assert member.role == 'chair', 'can use member.role but member.role was '+member.role.to_s
  	assert member.tier == 2, 'can use member.tier but member.tier was '+member.tier.to_s
  	assert member.permissions == 2, 'can use member.permissions but member.permissions was '+member.permissions.to_s
  end

  test 'committee member convenience methods work for member with no committee' do
  	assert true
  end


  test 'can get correct committee members.current_committee for member with committee' do 
    current_committee = members(:david).current_committee
    # gets actual committee
    assert current_committee.is_a?(Committee), 'current committee should be a committee'
    # gets correct committee\
    assert current_committee.name == 'Web Development'
  end

  test 'can get current committee for member without committee' do 
    current_committee = members(:eric).current_committee
    # gets actual committee
    assert current_committee.is_a?(Committee), 'current_committee should always return a committee'
    # gets gm
    assert current_committee.name = Committee.gm.name, 'if no current committee should return gm'
  end

   test 'no duplicate committee_members' do
    member = members(:member1)
    wd = committees(:wd)
    fall = semesters(:fall)
    spring = semesters(:spring)

    cm2 = CommitteeMember.new
    cm2.member_id = member.id
    cm2.semester_id = spring.id
    cm2.committee_id = wd.id
    cm2.position_id = 1
    assert cm2.save, 'should be able to save if different semesters'

    cm3 = CommitteeMember.new
    cm3.member_id = member.id
    cm3.semester_id = spring.id
    cm3.committee_id = wd.id
    cm3.position_id = 1
    assert_not cm3.save, 'cannot have two commitee members per semester'
  end


end
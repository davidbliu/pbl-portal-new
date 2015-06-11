require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase

""" test member commitments """

  test 'non nil commitments will be defaulted to valid' do
  	member = members(:no_commitment_member)
    assert member.save
  end

  test 'members must have array commitments' do
  	member = members(:no_commitment_member)
    member.commitments = "asdf"
    assert_not member.save
  end

  test 'member commitments must be array of 0 and 1' do
  	member = members(:no_commitment_member)
    member.commitments = ['a', 'b', 'c']
    assert_not member.save

    member.commitments = [0, 1, 2, 3]
    assert_not member.save
  end

  test 'member commitments must be correct length' do
  	member = members(:no_commitment_member)
    member.commitments = [0, 1, 0, 1]
    assert_not member.save

    member.commitments = Array.new(168)
    168.times{|i| member.commitments[i] = 0}
    assert member.save
  end

""" test committee members """

  test 'no duplicate committee_members' do
  	member = members(:no_commitment_member)
  	wd = committees(:wd)
    fall = semesters(:fall)
    spring = semesters(:spring)

    cm1 = CommitteeMember.new
    cm1.member_id = member.id
    cm1.committee_id = wd.id
    cm1.semester_id = fall.id
    assert cm1.save

    cm2 = CommitteeMember.new
    cm2.member_id = member.id
    cm2.semester_id = spring.id
    cm2.committee_id = wd.id
    assert cm2.save, 'should be able to save if different semesteres'

    cm3 = CommitteeMember.new
    cm3.member_id = member.id
    cm3.semester_id = spring.id
    cm3.committee_id = wd.id
    assert_not cm3.save, 'cannot have two commitee members per semester'
  end

  test 'can easily access member committee' do 
    assert true
  end

""" test member helper methods """


end

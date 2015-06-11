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
  	committee = committees(:wd)

    p CommitteeMember.all.length.to_s + ' committee members in the database'
    cm1 = CommitteeMember.new(member_id: member.id, committee_id: committee.id)
    assert cm1.save

    p CommitteeMember.all.length.to_s + ' committee members in the database'
    cm2 = CommitteeMember.new(member_id: member.id, committee_id: committee.id)
    assert cm2.save, 'should be able to save if different semesteres'

  end

""" test member helper methods """


end

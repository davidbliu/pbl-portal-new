require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase

""" test positions """

  test 'basic position test' do
  	committee_member = committee_members(:cm1)
  	assert committee_member.position.kind_of?(CommitteeMemberPosition), 'the position should be a kind of CommitteeMemberPosition'
  	assert committee_member.role == 'chair', 'cm1 should be a chair'
  	assert committee_member.permissions == 2, 'permissions should be 2'
  end

  test 'committee member convenience methods work' do 
  	member = members(:david)
  	assert member.role == 'chair', 'can use member.role'
  	assert member.tier == 3, 'can use member.tier'
  	assert member.permissions == 2, 'can use member.permissions'
  end

  test 'committee member convenience methods work for member with no committee' do
  	assert true
  end

end
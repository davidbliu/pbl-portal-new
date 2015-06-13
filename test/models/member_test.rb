require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase

""" test member commitments """

  test 'non nil commitments will be defaulted to valid' do
  	member = members(:member1)
    assert member.save
  end

  test 'members must have array commitments' do
  	member = members(:member1)
    member.commitments = "asdf"
    assert_not member.save
  end

  test 'member commitments must be array of 0 and 1' do
  	member = members(:member1)
    member.commitments = ['a', 'b', 'c']
    assert_not member.save

    member.commitments = [0, 1, 2, 3]
    assert_not member.save
  end

  test 'member commitments must be correct length' do
  	member = members(:member1)
    member.commitments = [0, 1, 0, 1]
    assert_not member.save

    member.commitments = Array.new(168)
    168.times{|i| member.commitments[i] = 0}
    assert member.save
  end

  test 'can easily access member committee' do 
    assert true
  end

""" test member helper methods """
  
test 'admin? works' do
  assert members(:david).admin?, 'wd chair should be admin'
  assert_not members(:random_gm).admin?, 'random gm should not be an admin'
  # exec should be considered admin
  assert members(:nathalie).admin?, 'execs should be admins'
end


end
